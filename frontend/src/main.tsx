import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import Login from "./Login";
// Loaded here rather than in App, so the login page is styled too.
import "./App.css";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <Login>
      <App />
    </Login>
  </StrictMode>,
);
