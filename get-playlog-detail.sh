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

API="https://www.solips.app/maimai/profile?_data=routes%2Fmaimai.profile"
source .env

while read playlogApiId
do
	curl -d "playlogApiId=$playlogApiId&requestType=getPlaylogDetail&accessCode=$ACCESS_CODE" -sS "$API"
	echo "$playlogApiId" >&2
	sleep 5
done | jq '.maimaiPlaylogDetail' | jq -s '{"playlogDetail": .}'
