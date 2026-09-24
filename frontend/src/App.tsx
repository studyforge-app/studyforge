import AsciiAnvil from "./AsciiAnvil";
import { supabase } from "./supabase";
import logo from "./assets/icons/studyforge-mark-black.svg";
import "./App.css";

export default function App() {
  return (
    <div className="page">
      <header className="header">
        <img className="header-logo" src={logo} alt="" />
        <span className="header-name">StudyForge</span>
        <button type="button" onClick={() => supabase.auth.signOut()}>
          Logout
        </button>
      </header>
      <main className="hero">
        <AsciiAnvil />
      </main>
    </div>
  );
}
