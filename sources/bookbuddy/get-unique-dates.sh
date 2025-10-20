csvjson BookBuddy.csv|jq -r '.[]."Date Added"' | cut -c 1-10|sort|uniq
