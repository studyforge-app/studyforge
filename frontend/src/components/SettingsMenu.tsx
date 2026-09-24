import { useEffect, useRef, useState } from "react";
import type { ThemeSetting } from "../useSettings";

const THEME_OPTIONS: { value: ThemeSetting; label: string }[] = [
  { value: "light", label: "hell" },
  { value: "system", label: "system" },
  { value: "dark", label: "dunkel" },
];

type SettingsMenuProps = {
  theme: ThemeSetting;
  onThemeChange: (theme: ThemeSetting) => void;
};

export default function SettingsMenu({ theme, onThemeChange }: SettingsMenuProps) {
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLDivElement>(null);

  // Close on a click outside the menu or on Escape.
  useEffect(() => {
    if (!open) return;
    const onPointerDown = (e: PointerEvent) => {
      if (!rootRef.current?.contains(e.target as Node)) setOpen(false);
    };
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    document.addEventListener("pointerdown", onPointerDown);
    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("pointerdown", onPointerDown);
      document.removeEventListener("keydown", onKeyDown);
    };
  }, [open]);

  return (
    <div className="settings" ref={rootRef}>
      <button
        type="button"
        className={`settings-toggle${open ? " is-open" : ""}`}
        aria-label="Einstellungen"
        aria-expanded={open}
        aria-controls="settings-panel"
        onClick={() => setOpen((o) => !o)}
      >
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
          <path d="M6 9l6 6 6-6" />
        </svg>
      </button>

      {open && (
        <div className="settings-panel" id="settings-panel" role="radiogroup" aria-label="Design">
          <span className="settings-label" aria-hidden="true">
            design
          </span>
          {THEME_OPTIONS.map((option) => (
            <button
              key={option.value}
              type="button"
              role="radio"
              aria-checked={theme === option.value}
              className="settings-option"
              onClick={() => onThemeChange(option.value)}
            >
              {option.label}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
