import Clock from "./components/Clock";
import Footer from "./components/Footer";
import Header from "./components/Header";
import { supabase } from "./supabase";

export default function App() {
  return (
    <div className="page">
      <Header>
        {/* App is only rendered behind the Login gate, so the user is always signed in here. */}
        <button type="button" className="login-button" onClick={() => supabase.auth.signOut()}>
          Abmelden
        </button>
      </Header>
      <main className="hero">
        <div className="hero-heading">
          <h1 className="page-title">Dashboard</h1>
          <Clock />
        </div>
      </main>
      <Footer />
    </div>
  );
}
