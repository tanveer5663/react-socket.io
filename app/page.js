"use client";
import { useEffect, useState } from "react";
import { io } from "socket.io-client";

console.log(process.env.NEXT_PUBLIC_URL); // connect to backend
const socket = io(process.env.NEXT_PUBLIC_URL);

function App() {
  const [message, setMessage] = useState("");
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    // Listen for messages from server
    socket.on("chatMessage", (msg) => {
      console.log(msg);
      setMessages((prev) => [...prev, msg]);
    });

    // Cleanup on unmount
    return () => {
      console.log("close connetion");
      socket.off("chatMessage");
    };
  }, []);

  const sendMessage = () => {
    if (message.trim()) {
      socket.emit("chatMessage", message); // send to server
      setMessage("");
    }
  };

  return (
    <div style={{ padding: "20px" }}>
      <h2>Socket.IO Chat (React)</h2>

      <div style={{ marginBottom: "10px" }}>
        <input
          type="text"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="Type a message..."
        />
        <button onClick={sendMessage}>Send</button>
      </div>

      <ul>
        {messages.map((msg, i) => (
          <li key={i}>{msg}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
