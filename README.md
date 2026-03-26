# Dial-A-Bot
A VOIP/SIP bridge to a Teamspeak server

## Usage
This container expects a volume mounted at `/config` inside the container with:

1. `pjsua.cfg` containing your VOIP connection details. Please see `pjsua.cfg.example` for usage.
2. `dialabot.cfg` containing the TeamSpeak ClientQuery connection settings:

```sh
TS3_SERVER_ADDRESS=voice.example.com
TS3_CLIENT_API_KEY=your-clientquery-api-key
```

`TS3_SERVER_ADDRESS` is passed directly to the TeamSpeak ClientQuery command `connect address=...`, so it should use the exact address format accepted by the TeamSpeak client.

### Teamspeak Initial setup
As Teamspeak does not provide an easy way to automate its settings & bookmark management, initial configuration must be done manually. Upon container first run, access the Teamspeak GUI by running `docker exec <container_name> vnc`, then connecting via VNC on port 5900.

Upon connecting via VNC, there are a few required steps:
1. Create a ClientQuery API key in the TeamSpeak client and place it in `/config/dialabot.cfg` as `TS3_CLIENT_API_KEY`.
2. Open Settings, and go to Playback. Change the playback device to TeamspeakPlayback.
3. Select Capture and change the capture device to TeamspeakCapture.
4. Save settings and close. Restart the container and verify the bot successfully connects on an incoming call and disconnects on hangup.

## Example run line

`docker run -d --name "DialABot" --restart on-failure:10 -v /path/to/config:/config Adam-Ant/DialABot`
