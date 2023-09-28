## Cosmos Chain Client Tools
Whenever possible, this tools will be made compatible with any chain based on the [Cosmos SDK](https://github.com/cosmos/cosmos-sdk)

![FreshSTAKING logo](https://pbs.twimg.com/profile_images/1539316263314370560/syHanQz4_200x200.jpg 'FreshSTAKING')

### Tools

#### 1) parse-output.sh:
appending `| ./parse-output.sh` (to a TX-generating cosmos client command) will **strip out unnecessary output, pick and highlight the relevant messages (errors or results), and streamline checking for a success/fail of the TX after it has been included in the block**. It has three possible outcomes:

a) command wasn't accepted (along with the reason why, stripping out any irrelevant information)

b) command was accepted and broadcasted to the network but not indexed (usually a temporary error, and the scripts gives up after 3 attemtps to find it indexed)

c) command was accepted, broadcasted to the network and indexed, and the result was success or fail (in which case the reason and only the reason why is displayed, stripping out any irrelevant information).

#### 2) check-upgrade.py:
Python script to be run on demand of via cron. It checks whether there is a planned upgrade, from your select set of networks, within a specified X amount of hours. Notifies any service you wish to use (PagerDuty, PushOver, Telegram, etc).

#### 3) peer-info.sh:
Bash script to show a daemon's peers, in the format ID@IP:port, followed by whether the peer is outbound or inbound, along with the peer's city according to an API query to an IP location service.

#### 4) peer-paste.sh:
Bash script to parse the output of an RPC's peerlist into a format ready to paste in persistent peers.
