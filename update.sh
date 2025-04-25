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

cd "$(dirname "$0")"
source .env

# ===========================
# Check environment variables
# ===========================

if [ -z "$ACCESS_CODE" ] || [ -z "$PLAYLOG" ] || [ -z "$INDEX_HTML" ] || [ -z "$PLAYLOG_DETAIL" ]
then
	echo missing environment variable >&2
	exit 1
fi

# ==========================
# Create temporary directory
# ==========================

TMP=$(mktemp -d)
trap 'rm -r -- "$TMP"' EXIT

# ==============
# Update playlog
# ==============

if [ -e "$PLAYLOG" ]
then
	cp "$PLAYLOG" "$PLAYLOG.$(date "+%s")"
else
	touch "$PLAYLOG"
fi

./get-playlog.sh > "$TMP/$PLAYLOG.new"

cat "$PLAYLOG" "$TMP/$PLAYLOG.new" | jq -s '
	.[0].playlog + .[1].playlog | 
	group_by(.info.userPlayDate) |
	map(.[0]) |
	reverse |
	{"playlog": .}' > "$TMP/$PLAYLOG.tmp"

mv "$TMP/$PLAYLOG.tmp" "$PLAYLOG"

# =======================
# Create static html file
# =======================

#./process-data.sh "$PLAYLOG" > "$TMP/index.html.tmp"
#mv "$TMP/index.html.tmp" "$INDEX_HTML"

# =======================
# Update detailed playlog
# =======================

if [ -e "$PLAYLOG_DETAIL" ]
then
	cp "$PLAYLOG_DETAIL" "$PLAYLOG_DETAIL.$(date "+%s")"
else
	touch "$PLAYLOG_DETAIL"
fi

cat "$PLAYLOG" | jq '.playlog[].info.userPlayDate' | sort > "$TMP/playlog-dates"
cat "$PLAYLOG_DETAIL" | jq '.playlogDetail[].info.userPlayDate' | sort > "$TMP/playlog-detail-dates"

comm -23 "$TMP/playlog-dates" "$TMP/playlog-detail-dates" | \
	while read date
	do
		cat "$PLAYLOG" | jq ".playlog[] |
				select(.info.userPlayDate == $date) |
				.playlogApiId"
	done | sed 's/"//g' | \
	./get-playlog-detail.sh > "$TMP/$PLAYLOG_DETAIL.new"

cat "$PLAYLOG_DETAIL" "$TMP/$PLAYLOG_DETAIL.new" | jq -s '
	.[0].playlogDetail + .[1].playlogDetail |
	group_by(.info.userPlayDate) |
	map(.[0]) |
	reverse |
	{"playlogDetail": .}' > "$TMP/$PLAYLOG_DETAIL.tmp"

mv "$TMP/$PLAYLOG_DETAIL.tmp" "$PLAYLOG_DETAIL"
