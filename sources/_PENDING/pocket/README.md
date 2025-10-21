I tried 3 ways to get an export:

1. Pocket has an Export option on the web site

  Did this Jul 6 2025 (2 days before Pocket shutdown)

  It emailed me my export within a couple minutes. That's the `pocket.zip` file.

2. Tried this github repo  pocket-cli, but didn't get it to work.

  <https://github.com/ozbe/pocket-cli>

3. They have a Very Unhelpful web page

  Sometime back in the midsts of time, I followed the instructions here:
  <https://getpocket.com/developer/docs/authentication>

  Caveats:
  -Who knows if at that time the content of that site was different than now.
  - It's designed for app developers.
  - It's a PITA if all you want to do is download your shit.

  This is what I did: 
  - Saved the consumer ID (I used the Web one), access_token to 1Password.
  - Then did https://getpocket.com/v3/get
    - It looks to me like the API changed afterwards, especially since it only acceptsd POST now.
