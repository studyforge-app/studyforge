import { useEffect, useState, type FormEvent, type ReactNode } from "react";
import type { Session } from "@supabase/supabase-js";
import { supabase } from "./supabase";
import Footer from "./components/Footer";
import Header from "./components/Header";

type Mode = "login" | "register";

// Supabase returns English messages; map the common ones to German.
function translateError(message: string): string {
  const text = message.toLowerCase();
  if (text.includes("invalid login credentials")) return "E-Mail oder Passwort ist falsch";
  if (text.includes("rate limit")) return "Zu viele Versuche. Bitte später erneut probieren";
  if (text.includes("already registered")) return "Diese E-Mail ist bereits registriert";
  if (text.includes("email not confirmed")) return "Bitte bestätige zuerst deine E-Mail";
  if (text.includes("password should be at least")) return "Das Passwort ist zu kurz";
  if (text.includes("invalid") && text.includes("email")) return "Die E-Mail-Adresse ist ungültig";
  return message;
}

// Login gate: renders children only once a Supabase session exists.
// Sign-up fires the on_auth_user_created trigger, which creates the profile row.
export default function Login({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  const [mode, setMode] = useState<Mode>("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [passwordRepeat, setPasswordRepeat] = useState("");
  const [message, setMessage] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setLoading(false);
    });
    const { data } = supabase.auth.onAuthStateChange((_event, newSession) => {
      setSession(newSession);
    });
    return () => data.subscription.unsubscribe();
  }, []);

  if (loading) return null;
  if (session) return <>{children}</>;

  function switchMode(next: Mode) {
    setMode(next);
    setMessage(null);
    setPasswordRepeat("");
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setMessage(null);

    if (mode === "register") {
      if (password !== passwordRepeat) {
        setMessage("Die Passwörter stimmen nicht überein");
        return;
      }
      setSubmitting(true);
      const { data, error } = await supabase.auth.signUp({ email, password });
      setSubmitting(false);
      if (error) setMessage(translateError(error.message));
      else if (!data.session) setMessage("Bestätige deine E-Mail über den Link, den wir dir geschickt haben");
      return;
    }

    setSubmitting(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setSubmitting(false);
    if (error) setMessage(translateError(error.message));
  }

  const isLogin = mode === "login";

  return (
    <div className="page">
      <Header />
      <main className="hero">
        <div className="auth">
          <h1 className="page-title">{isLogin ? "Anmelden" : "Registrieren"}</h1>

          {/* No labels or lines: placeholders mark the fields, aria-label names them for screen readers. */}
          <form className="auth-form" onSubmit={handleSubmit}>
            <input
              className="auth-input"
              type="email"
              placeholder="E-Mail"
              aria-label="E-Mail"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <input
              className="auth-input"
              type="password"
              placeholder="Passwort"
              aria-label="Passwort"
              autoComplete={isLogin ? "current-password" : "new-password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
            {!isLogin && (
              <input
                className="auth-input"
                type="password"
                placeholder="Passwort wiederholen"
                aria-label="Passwort wiederholen"
                autoComplete="new-password"
                value={passwordRepeat}
                onChange={(e) => setPasswordRepeat(e.target.value)}
                required
              />
            )}

            {message && (
              <p className="auth-message" role="alert">
                {message}
              </p>
            )}

            <button type="submit" className="login-button auth-submit" disabled={submitting}>
              Weiter <span className="auth-arrow">→</span>
            </button>
          </form>

          <p className="auth-switch">
            {isLogin ? "Noch kein Konto? " : "Schon ein Konto? "}
            <button type="button" className="auth-switch-button" onClick={() => switchMode(isLogin ? "register" : "login")}>
              {isLogin ? "Registrieren" : "Anmelden"}
            </button>
          </p>
        </div>
      </main>
      <Footer />
    </div>
  );
}
