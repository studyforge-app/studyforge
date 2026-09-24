import { useEffect, useState } from "react";

const dateFormatter = new Intl.DateTimeFormat("de-DE", { weekday: "long", day: "numeric", month: "long" });
const timeFormatter = new Intl.DateTimeFormat("de-DE", { hour: "2-digit", minute: "2-digit" });

export default function Clock() {
  const [now, setNow] = useState(() => new Date());

  useEffect(() => {
    let interval = 0;
    // Wait until the next full minute, then tick every minute, so the display
    // switches exactly when the minute (and at midnight the date) changes.
    const msToNextMinute = 60_000 - (Date.now() % 60_000);
    const timeout = window.setTimeout(() => {
      setNow(new Date());
      interval = window.setInterval(() => setNow(new Date()), 60_000);
    }, msToNextMinute);

    return () => {
      window.clearTimeout(timeout);
      window.clearInterval(interval);
    };
  }, []);

  return (
    <time className="clock" dateTime={now.toISOString()}>
      <span>{dateFormatter.format(now)}</span>
      <span>{timeFormatter.format(now)}</span>
    </time>
  );
}
