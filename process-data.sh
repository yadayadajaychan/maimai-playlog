#!/usr/bin/env bash

# Copyright (C) 2025 Ethan Cheng
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

TMP=$(mktemp -d)
trap 'rm -r -- "$TMP"' EXIT

cp playlog.json "$TMP/"

echo "
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="author" content="Ethan Cheng">

	<style>
	table {
		display: inline-block;
		margin-right: 10px;
		vertical-align: top;
		border: 1px solid black;
		text-align: right
	}
	td, th {
		border: 1px solid black;
		padding: 8px;
	}
	</style>
</head>
<body>
<p>Last updated: $(date -Iseconds)</p>
<hr>
"

cat "$TMP/playlog.json" | jq --slurpfile songs songs.json -r '
	.playlog |
	.[] |
	.info + .judge |
	.musicId as $song_id |
	. + ($songs[][] | select(.song_id == $song_id)) |

	"<p><img width=\"190\" height=\"190\" src=\"\(.musicId).png\" loading=\"lazy\"></p>
	<p><strong>\(.name)</strong><br>
	\(.artist)</p>" +
	"<p>" +
	(.level | sub("MAIMAI_LEVEL_"; "")) +
	" LV " +
	(.level as $level | .charts[] | select(.difficulty == ($level | sub("MAIMAI_LEVEL_"; "") | ascii_downcase )) | .internal_level | tostring) +
	"</p>" +
	"<p><strong>" + 
	(.achievement / 10000 | tostring) + "% " +
	(.scoreRank | sub("MAIMAI_SCORE_RANK_"; ""; "g") | sub("_PLUS"; "+"; "g")) +
	"</strong></p> 
	<p>
	<table class=\"judgement-table\">
		<tr> <td>Critical<br>Perfect</td> <td>\(.judgeCriticalPerfect)</td> </tr>
		<tr> <td>Perfect</td> <td>\(.judgePerfect)</td> </tr>
		<tr> <td>Great</td> <td>\(.judgeGreat)</td> </tr>
		<tr> <td>Good</td> <td>\(.judgeGood)</td> </tr>
		<tr> <td>Miss</td> <td>\(.judgeMiss)</td> </tr>
	</table>
	<table class=\"judgement-table\">
		<tr> <td>Max<br>Combo</td> <td>\(.maxCombo)</td> </tr>
		<tr> <td>Fast</td> <td>\(.fastCount)</td> </tr>
		<tr> <td>Late</td> <td>\(.lateCount)</td> </tr>
	</table></p>
	<p>
	Played on: \(.userPlayDate)<hr>
	</p>"
	'

echo "</body></html>"
