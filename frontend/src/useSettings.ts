import { useEffect, useState } from "react";

export type ThemeSetting = "light" | "system" | "dark";

const THEME_KEY = "studyforge-theme";

// Storage can be unavailable (private mode, blocked site data), so every access is guarded.
function loadTheme(): ThemeSetting {
  try {
    const stored = localStorage.getItem(THEME_KEY);
    return stored === "light" || stored === "dark" ? stored : "system";
  } catch {
    return "system";
  }
}

function saveTheme(theme: ThemeSetting) {
  try {
    localStorage.setItem(THEME_KEY, theme);
  } catch {
    // The setting just won't persist.
  }
}

export function useSettings() {
  const [theme, setTheme] = useState<ThemeSetting>(loadTheme);

  useEffect(() => {
    // "system" removes the override, so the CSS falls back to prefers-color-scheme.
    const root = document.documentElement;
    if (theme === "system") delete root.dataset.theme;
    else root.dataset.theme = theme;
    saveTheme(theme);
  }, [theme]);

  return { theme, setTheme };
}
