import type { ReactNode } from "react";
import SettingsMenu from "./SettingsMenu";
import { useSettings } from "../useSettings";
import logo from "../assets/icons/studyforge-mark-black.svg";

// Shared by the login page and the dashboard. Page-specific actions (e.g. "Abmelden")
// go in children and appear left of the settings arrow.
export default function Header({ children }: { children?: ReactNode }) {
  const { theme, setTheme } = useSettings();

  return (
    <header className="header">
      <img className="header-logo" src={logo} alt="" />
      <span className="header-name">StudyForge</span>
      <div className="header-actions">
        {children}
        <SettingsMenu theme={theme} onThemeChange={setTheme} />
      </div>
    </header>
  );
}
