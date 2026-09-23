/**
 * pi footer restyled to match the Claude Code statusline
 * (see claude/statusline-command.sh). Keeps every field the built-in footer
 * shows, collapsed onto a single line.
 *
 * Not reproducible here: the "(auto)" auto-compaction indicator — it lives on
 * session.autoCompactionEnabled, which the extension API does not expose.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// Catppuccin Mocha
const GREEN = "\x1b[38;2;166;227;161m";
const YELLOW = "\x1b[38;2;249;226;175m";
const RED = "\x1b[38;2;243;139;168m";
const GRAY = "\x1b[38;2;108;112;134m";
const RESET = "\x1b[0m";

// Nerd Font glyphs. Ghostty bundles "Symbols Nerd Font" as a fallback face,
// so these render without installing anything — but only inside Ghostty.
const ICON_MODEL = "󰚩";
const ICON_BRANCH = "";
const ICON_DIR = "";
const ICON_SESSION = "󰆓";
// Battery levels, index 0 (empty) .. 9 (full)
const BATTERY = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁿", "󰂀", "󰂁", "󰂂", "󰂃"];

const SEP = `${GRAY} │ ${RESET}`;

function batteryForPct(pct: number): string {
	return BATTERY[Math.min(9, Math.floor(pct / 10))];
}

function colorForPct(pct: number): string {
	if (pct >= 80) return RED;
	if (pct >= 50) return YELLOW;
	return GREEN;
}

/** Same thresholds and rounding as the built-in footer. */
function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function formatCwd(cwd: string): string {
	const home = process.env.HOME || process.env.USERPROFILE;
	if (!home) return cwd;
	if (cwd === home) return "~";
	return cwd.startsWith(`${home}/`) ? `~${cwd.slice(home.length)}` : cwd;
}

function sanitizeStatusText(text: string): string {
	return text
		.replace(/[\r\n\t]/g, " ")
		.replace(/ +/g, " ")
		.trim();
}

type Totals = { input: number; output: number; cacheRead: number; cacheWrite: number; cost: number };

/** Cumulative usage over ALL entries, matching the built-in footer's accounting. */
function collectTotals(ctx: ExtensionContext): { totals: Totals; latestCacheHitRate?: number } {
	const totals: Totals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
	let latestCacheHitRate: number | undefined;
	const add = (usage: any) => {
		totals.input += usage.input;
		totals.output += usage.output;
		totals.cacheRead += usage.cacheRead;
		totals.cacheWrite += usage.cacheWrite;
		totals.cost += usage.cost.total;
	};
	for (const entry of ctx.sessionManager.getEntries() as any[]) {
		if (entry.type === "message" && entry.message.role === "assistant") {
			add(entry.message.usage);
			const prompt = entry.message.usage.input + entry.message.usage.cacheRead + entry.message.usage.cacheWrite;
			latestCacheHitRate = prompt > 0 ? (entry.message.usage.cacheRead / prompt) * 100 : undefined;
		} else if (entry.type === "message" && entry.message.role === "toolResult" && entry.message.usage) {
			add(entry.message.usage);
		} else if ((entry.type === "branch_summary" || entry.type === "compaction") && entry.usage) {
			add(entry.usage);
		}
	}
	return { totals, latestCacheHitRate };
}

/** Kimi Coding is subscription-backed despite using API-key authentication. */
function usingSubscription(ctx: ExtensionContext): boolean {
	const model = ctx.model;
	if (!model) return false;
	if (model.provider === "kimi-coding") return true;
	return (
		ctx.modelRegistry.isUsingOAuth(model) &&
		(ctx.modelRegistry.getProvider(model.provider) as any)?.auth?.oauth?.isSubscription === true
	);
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					const parts: string[] = [];

					// Model, with provider prefix when several providers are configured
					const model = ctx.model;
					let modelPart = model?.id ?? "no-model";
					if (model && footerData.getAvailableProviderCount() > 1) {
						modelPart = `(${model.provider}) ${modelPart}`;
					}
					if (model?.reasoning) {
						const level = ctx.thinkingLevel || "off";
						modelPart += level === "off" ? " • thinking off" : ` • ${level}`;
					}
					parts.push(`${ICON_MODEL} ${modelPart}`);

					// Context usage: unknown right after compaction, until the next response
					const usage = ctx.getContextUsage();
					const window = usage?.contextWindow ?? model?.contextWindow ?? 0;
					const pct = usage?.percent ?? null;
					if (pct === null) {
						parts.push(`${GRAY}?/${formatTokens(window)}${RESET}`);
					} else {
						const color = colorForPct(pct);
						parts.push(`${color}${batteryForPct(pct)} ${pct.toFixed(1)}%/${formatTokens(window)}${RESET}`);
					}

					const { totals, latestCacheHitRate } = collectTotals(ctx);
					const sub = usingSubscription(ctx);
					// Shown even at zero so the segment layout does not shift on the first response
					parts.push(`$${totals.cost.toFixed(3)}${sub ? " (sub)" : ""}`);

					const tokenParts: string[] = [];
					if (totals.input) tokenParts.push(`↑${formatTokens(totals.input)}`);
					if (totals.output) tokenParts.push(`↓${formatTokens(totals.output)}`);
					if (totals.cacheRead) tokenParts.push(`R${formatTokens(totals.cacheRead)}`);
					if (totals.cacheWrite) tokenParts.push(`W${formatTokens(totals.cacheWrite)}`);
					if ((totals.cacheRead > 0 || totals.cacheWrite > 0) && latestCacheHitRate !== undefined) {
						tokenParts.push(`CH${latestCacheHitRate.toFixed(1)}%`);
					}
					if (tokenParts.length) parts.push(tokenParts.join(" "));

					if (process.env.PI_EXPERIMENTAL === "1") parts.push(`${YELLOW}xp${RESET}`);

					const branch = footerData.getGitBranch();
					if (branch) parts.push(`${ICON_BRANCH} ${branch}`);

					parts.push(`${ICON_DIR} ${formatCwd(ctx.sessionManager.getCwd())}`);

					const sessionName = ctx.sessionManager.getSessionName();
					if (sessionName) parts.push(`${ICON_SESSION} ${sessionName}`);

					const line = parts.join(SEP);
					const lines = [visibleWidth(line) > width ? truncateToWidth(line, width, "...") : line];

					// Other extensions' setStatus texts keep their own line, as in the built-in footer
					const statuses = footerData.getExtensionStatuses();
					if (statuses.size > 0) {
						const text = Array.from(statuses.entries())
							.sort(([a], [b]) => a.localeCompare(b))
							.map(([, t]) => sanitizeStatusText(t))
							.join(" ");
						lines.push(truncateToWidth(text, width, `${GRAY}...${RESET}`));
					}

					return lines;
				},
			};
		});
	});
}
