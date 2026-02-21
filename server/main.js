var OAUTH_TOKEN = ""; // include "oauth:"
var ACCESS_TOKEN = "";
const CLIENT_ID = "tztqbknddp0rfm2wmfkjvckjc4in5j";
var USER_ID = "";
var CHANNEL = "";

var hasData = false;

async function getData() {
    await fetch("http://localhost:3000/data")
        .then(res => res.json())
        .then(data => {
            if (data.notReady) {
                console.warn("Data not ready yet, retrying in 1 second...");
                setParagraphText("Data not ready yet, retrying in 1 second... (if this keeps happening close the page and open it again with 'open dashboad' in config)", "getting-data");
                setTimeout(getData, 1000);
                return;
            }
            setParagraphText("Data Gotten", "getting-data");
            setParagraphColor("#1100ff", "getting-data");
            console.log("Received data:", data);
            OAUTH_TOKEN = "oauth:" + data.access_token;
            ACCESS_TOKEN = data.access_token;
            USER_ID = data.user_id;
            CHANNEL = data.channel;
            hasData = true;

        })
        .catch(err => {
            console.error("Error fetching data:", err);
            setParagraphText("Error getting Data", "getting-data");
            setParagraphColor("#ff0000", "getting-data");
        });

}



function connectChat() {
    if (!hasData) {
        console.error("Cannot connect to chat without data");
         setTimeout(connectChat, 1000);
        return;
    }
    const ws = new WebSocket("wss://irc-ws.chat.twitch.tv:443");

    ws.addEventListener("open", () => {
        ws.send(`PASS ${OAUTH_TOKEN}`);
        ws.send(`NICK ${CHANNEL}`);
        ws.send(`JOIN #${CHANNEL}`);
        console.log("Connected to chat");
        setParagraphText("Connected to Chat", "connect-chat");
        setParagraphColor("#002fff", "connect-chat");
    });

    ws.addEventListener("message", (data) => {
        console.log("Received chat message:", data);
        const msg = data.data.toString();
        if (msg.includes("PING")) {
            ws.send("PONG :tmi.twitch.tv");
            return;
        }
        const match = msg.match(/:(\w+)!\w+@\w+\.tmi\.twitch\.tv PRIVMSG #\w+ :(.*)/);
        if (match) {
            const username = match[1];
            const message = match[2];
            fetch("http://localhost:3000/chat?=username=" + username + "&message=" + message);
        }
    });
}

// ---------- EVENTSUB (WebSocket) ----------
let sessionId = null;

function connectEventSub() {
    if (!hasData) {
        console.error("Cannot connect to EventSub without data");
         setTimeout(connectEventSub, 1000);
        return;
    }
    // const ws = new WebSocket("wss://eventsub.wss.twitch.tv/ws");
    const ws = new WebSocket("ws://localhost:8080/ws");

    ws.addEventListener("message", async (data) => {
        // data = data.toString();
        console.log("Received EventSub message:", data.data);
        const msg = JSON.parse(data.data);
        // const msg = data;

        if (msg.metadata.message_type === "session_welcome") {
            sessionId = msg.payload.session.id;
            console.log("EventSub connected");


            await subscribe("channel.follow", "2");
            await subscribe("channel.subscribe", "1");
            await subscribe("channel.cheer", "1");
            await subscribe("channel.poll.end", "1");


        }

        if (msg.metadata.message_type === "notification") {
            const event = msg.payload.event;

            switch (msg.metadata.subscription_type) {
                case "channel.follow":
                    console.log(`${event.user_name} followed!`);
                    fetch("http://localhost:3000/follow?username=" + event.user_name);
                    break;

                case "channel.subscribe":
                    console.log(`${event.user_name} subscribed (${event.tier})`);
                    fetch("http://localhost:3000/subscribe?username=" + event.user_name + "&tier=" + event.tier);
                    break;

                case "channel.cheer":
                    console.log(`${event.user_name} cheered ${event.bits} bits!`);
                    fetch("http://localhost:3000/cheer?username=" + event.user_name + "&bits=" + event.bits);
                    break;
                case "channel.poll.end":
                    console.log(`Poll: ${event.title} ended with the shoices: ${JSON.stringify(event.choices)}`)
                    const bodyStr = JSON.stringify(event.choices);
                    console.log("sending poll_end body", bodyStr);
                    fetch("http://localhost:3000/poll_end", {
                        method: "PUT",
                        headers: { "Content-Type": "application/json" },
                        body: bodyStr
                    })

            }
        }
    });
}

// ---------- SUBSCRIBE ----------
async function subscribe(type, version) {
    const body = {
        type,
        version,
        condition: {
            broadcaster_user_id: USER_ID,
            moderator_user_id: USER_ID
        },
        transport: {
            method: "websocket",
            session_id: sessionId
        }
    };

    const res = await fetch("https://api.twitch.tv/helix/eventsub/subscriptions", {
        method: "POST",
        headers: {
            "Client-ID": CLIENT_ID,
            "Authorization": `Bearer ${ACCESS_TOKEN}`,
            "Content-Type": "application/json"
        },
        body: JSON.stringify(body)
    });

    const json = await res.json();
    const err = json.error;
    if (type == "channel.follow") {
        setParagraphText(`Subscribed to Channel.follow`, "subscribe-follow");
        setParagraphColor("#0004ff", "subscribe-follow");
    } else if (type == "channel.subscribe") {
        setParagraphText(`Subscribed to channel.Subscribe`, "subscribe-subscribe");
        setParagraphColor("#0004ff", "subscribe-subscribe");
    } else if (type == "channel.cheer") {
        setParagraphText("Subscribed to Channel.cheer", "subscribe-cheer");
        setParagraphColor("#1100ff", "subscribe-cheer");
    }
    console.log(`Subscribed to ${type}`, json);
    
    // if (err) {
    //     console.error(`Error subscribing to ${type}:`, json);
    //     setParagraphText(`Error subscribing to ${type}`, className);
    //     setParagraphColor("#ff0000", className);
    //     return;
    // }
}

async function ping() {
    fetch("http://localhost:3000/ping")
        .then(res => res.text())
        .then(data => {
            console.log("Ping response:", data);
        })
        .catch(err => {
            console.error("Error pinging server:", err);
        }); 
    await new Promise(resolve => setTimeout(resolve, 1000));
}

// ---------- APPEARANCE HELPERS ----------

/**
 * Set the color of all <p> elements or only those matching a class.
 * @param {string} color - any valid CSS color (e.g. "red" or "#00f").
 * @param {string} [className] - optional class to restrict which paragraphs are changed.
 */
function setParagraphColor(color, className) {
    const selector = className ? `p.${className}` : 'p';
    document.querySelectorAll(selector).forEach(p => {
        p.style.color = color;
    });
}

/**
 * Resize paragraphs by supplying a CSS font-size value.
 * Optionally restrict to a class name.
 * Example: setParagraphSize('3rem');
 *          setParagraphSize('2rem','connect-chat');
 */
function setParagraphSize(size, className) {
    const selector = className ? `p.${className}` : 'p';
    document.querySelectorAll(selector).forEach(p => {
        p.style.fontSize = size;
    });
}

/**
 * Change the inner text of paragraphs. Can target by class.
 * @param {string} text - New text to apply.
 * @param {string} [className] - Optional class to restrict which paragraphs are changed.
 */
function setParagraphText(text, className) {
    const selector = className ? `p.${className}` : 'p';
    document.querySelectorAll(selector).forEach(p => {
        p.textContent = text;
    });
}

// ---------- START ----------

setParagraphText("Getting Data...", "getting-data");
setParagraphColor("#222", "getting-data");
setParagraphSize("2rem", "getting-data");
getData();

setParagraphText("Connecting to Chat", "connect-chat");
setParagraphColor("#000000", "connect-chat");
setParagraphSize("2rem", "connect-chat");
connectChat();


setParagraphText("Subscribing to Channel.follow", "subscribe-follow");
setParagraphColor("#000000", "subscribe-follow");
setParagraphSize("2rem", "subscribe-follow");

setParagraphText("Subscribing to Channel.subscribe", "subscribe-subscribe");
setParagraphColor("#000000", "subscribe-subscribe");
setParagraphSize("2rem", "subscribe-subscribe");


setParagraphText("Subscribing to Channel.cheer", "subscribe-cheer");
setParagraphColor("#000000", "subscribe-cheer");
setParagraphSize("2rem", "subscribe-cheer");
connectEventSub();

ping();