#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IOS_APP="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitApp/PakFitScreens.swift"
IOS_MODELS="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitModels.swift"
IOS_ENGINES="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCore/PakFitEngines.swift"
IOS_SMOKE_TESTS="$ROOT_DIR/ios/PakFitIOS/Sources/PakFitCoreSmokeTests/main.swift"
DOC_FILE="$ROOT_DIR/docs/ios-analysis-dashboard-parity.md"
STORE_LISTING="$ROOT_DIR/docs/store-listing.md"

for required_file in "$IOS_APP" "$IOS_MODELS" "$IOS_ENGINES" "$IOS_SMOKE_TESTS" "$DOC_FILE" "$STORE_LISTING"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing iOS analysis dashboard parity gate input: $required_file" >&2
    exit 1
  fi
done

require_text() {
  local file="$1"
  local text="$2"
  local description="$3"
  if ! grep -Fq "$text" "$file"; then
    echo "$description is missing from $file: $text" >&2
    exit 1
  fi
}

require_text "$IOS_MODELS" "public enum TrendStatus" "iOS trend status model"
require_text "$IOS_MODELS" "public enum TodoType" "iOS todo type model"
require_text "$IOS_MODELS" "public struct ChartPoint" "iOS chart point model"
require_text "$IOS_MODELS" "public struct TrendInsight" "iOS trend insight model"
require_text "$IOS_MODELS" "public struct AnalysisTodo" "iOS analysis todo model"
require_text "$IOS_MODELS" "public struct HistoryEntry" "iOS history entry model"
require_text "$IOS_MODELS" "public struct AnalysisDashboard" "iOS analysis dashboard model"
require_text "$IOS_ENGINES" "public final class AnalysisDashboardEngine" "iOS analysis dashboard engine"
require_text "$IOS_ENGINES" "weeklySummary" "iOS weekly summary calculation"
require_text "$IOS_ENGINES" "monthlySummary" "iOS monthly summary calculation"
require_text "$IOS_ENGINES" "calorieTrend" "iOS calorie trend calculation"
require_text "$IOS_ENGINES" "burnTrend" "iOS burn trend calculation"
require_text "$IOS_ENGINES" "buildChartPoints" "iOS chart point calculation"
require_text "$IOS_ENGINES" "adherenceScore" "iOS adherence score calculation"
require_text "$IOS_SMOKE_TESTS" "AnalysisDashboardEngine" "iOS analysis dashboard smoke test"
require_text "$IOS_SMOKE_TESTS" "dashboard.chartPoints.count" "iOS chart point smoke coverage"
require_text "$IOS_SMOKE_TESTS" "dashboard.history.first?.date" "iOS history smoke coverage"

require_text "$IOS_APP" "private let analysisEngine = AnalysisDashboardEngine()" "iOS analysis engine wiring"
require_text "$IOS_APP" "var analysisDashboard: AnalysisDashboard" "iOS analysis dashboard view-model output"
require_text "$IOS_APP" "AnalysisDashboardPanel(dashboard: model.analysisDashboard)" "iOS analysis dashboard placement"
require_text "$IOS_APP" 'Panel(title: "Analysis Dashboard")' "iOS analysis dashboard panel"
require_text "$IOS_APP" 'Panel(title: "Charts & Graphs")' "iOS charts and graphs panel"
require_text "$IOS_APP" 'Panel(title: "Trends")' "iOS trends panel"
require_text "$IOS_APP" 'Panel(title: "Todo")' "iOS todo panel"
require_text "$IOS_APP" 'Panel(title: "History")' "iOS history panel"
require_text "$IOS_APP" "DashboardProgressRow" "iOS dashboard progress rows"
require_text "$IOS_APP" "AnalysisBarChart" "iOS analysis chart rows"
require_text "$IOS_APP" "TrendInsightRow" "iOS trend rendering"
require_text "$IOS_APP" "AnalysisTodoRow" "iOS todo rendering"
require_text "$IOS_APP" "SummaryLine" "iOS summary rendering"
require_text "$IOS_APP" ".accessibilityLabel" "iOS analysis accessibility labels"

require_text "$DOC_FILE" "iOS analysis dashboard parity" "iOS analysis dashboard parity documentation"
require_text "$DOC_FILE" "Adherence score" "iOS adherence documentation"
require_text "$DOC_FILE" "Weekly summaries" "iOS weekly documentation"
require_text "$DOC_FILE" "Monthly summaries" "iOS monthly documentation"
require_text "$DOC_FILE" "Charts and graphs" "iOS chart documentation"
require_text "$DOC_FILE" "Trend insights" "iOS trend documentation"
require_text "$DOC_FILE" "Todos" "iOS todo documentation"
require_text "$DOC_FILE" "Newest-first history" "iOS history documentation"
require_text "$STORE_LISTING" "Review analysis dashboard, weekly summaries, monthly summaries, charts, graphs, trends, todos, and history on Android and iOS." "Store listing iOS analysis dashboard parity copy"

echo "iOS analysis dashboard parity gate passed."
