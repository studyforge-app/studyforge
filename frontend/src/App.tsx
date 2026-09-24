import Clock from "./components/Clock";
import SettingsMenu from "./components/SettingsMenu";
import { useSettings } from "./useSettings";
import logo from "./assets/icons/studyforge-mark-black.svg";
import "./App.css";

export default function App() {
  const { theme, setTheme } = useSettings();

  return (
    <div className="page">
      <header className="header">
        <img className="header-logo" src={logo} alt="" />
        <span className="header-name">StudyForge</span>
        <div className="header-actions">
          {/* No action yet, login comes with Supabase auth. */}
          <button type="button" className="login-button">
            Anmelden
          </button>
          <SettingsMenu theme={theme} onThemeChange={setTheme} />
        </div>
      </header>
      <main className="hero">
        <div className="hero-heading">
          <h1 className="page-title">Dashboard</h1>
          <Clock />
        </div>
      </main>
      <footer className="footer">
        <span>© {new Date().getFullYear()} StudyForge</span>
        <span>Leon Molkenthin, Finn Krause, Kai Krabichler</span>
      </footer>
    </div>
  );
}
