import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import Login from "./Login";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <Login>
      <App />
    </Login>
  </StrictMode>,
);
