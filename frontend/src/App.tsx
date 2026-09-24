import AsciiAnvil from "./AsciiAnvil";
import logo from "./assets/icons/studyforge-mark-black.svg";
import "./App.css";

export default function App() {
  return (
    <div className="page">
      <header className="header">
        <img className="header-logo" src={logo} alt="" />
        <span className="header-name">StudyForge</span>
      </header>
      <main className="hero">
        <AsciiAnvil />
      </main>
    </div>
  );
}
