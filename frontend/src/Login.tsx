import { useEffect, useState, type FormEvent, type ReactNode } from "react";
import type { Session } from "@supabase/supabase-js";
import { supabase } from "./supabase";

type Mode = "login" | "register";

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
        setMessage("Passwords do not match");
        return;
      }
      setSubmitting(true);
      const { data, error } = await supabase.auth.signUp({ email, password });
      setSubmitting(false);
      if (error) setMessage(error.message);
      else if (!data.session) setMessage("Check your email to confirm your account");
      return;
    }

    setSubmitting(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setSubmitting(false);
    if (error) setMessage(error.message);
  }

  return (
    <div>
      <button type="button" onClick={() => switchMode("login")} disabled={mode === "login"}>
        Login
      </button>
      <button type="button" onClick={() => switchMode("register")} disabled={mode === "register"}>
        Register
      </button>

      <form onSubmit={handleSubmit}>
        <div>
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </div>
        <div>
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>
        {mode === "register" && (
          <div>
            <input
              type="password"
              placeholder="Repeat password"
              value={passwordRepeat}
              onChange={(e) => setPasswordRepeat(e.target.value)}
              required
            />
          </div>
        )}
        <button type="submit" disabled={submitting}>
          {mode === "login" ? "Login" : "Register"}
        </button>
      </form>

      {message && <p>{message}</p>}
    </div>
  );
}
