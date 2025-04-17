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

source .env

# ==============
# Update playlog
# ==============

if [ -e "$PLAYLOG" ]
then
	cp "$PLAYLOG" "$PLAYLOG.$(date "+%s")"
fi

./get-playlog.sh > "$PLAYLOG.new"

cat "$PLAYLOG" "$PLAYLOG.new" | jq -s '
	.[0].playlog + .[1].playlog | 
	group_by(.info.userPlayDate) |
	map(.[0]) |
	reverse |
	{"playlog": .}' > "$PLAYLOG.tmp"

mv "$PLAYLOG.tmp" "$PLAYLOG"
rm "$PLAYLOG.new"
