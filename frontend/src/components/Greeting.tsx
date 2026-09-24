import { useEffect, useState } from "react";

const PREFIX = "Hallo, ";
const PLACEHOLDER_NAMES = ["Leon", "Finn", "Kai"];

const START_DELAY = 400; // pause before typing starts (ms)
const TYPE_DELAY = 70; // base delay per typed character
const TYPE_JITTER = 50; // random extra delay, makes the typing feel human
const COMMA_PAUSE = 250; // extra pause after the comma
const HOLD_DELAY = 1600; // how long a placeholder name stays before it is deleted
const DELETE_DELAY = 45; // delay per deleted character
const NEXT_NAME_DELAY = 300; // pause after deleting, before the next name is typed

function typingDelay(): number {
  return TYPE_DELAY + Math.random() * TYPE_JITTER;
}

type GreetingProps = {
  // Without a name the placeholder names are typed, deleted and cycled endlessly.
  // With a name it is typed once and stays.
  name?: string;
};

export default function Greeting({ name }: GreetingProps) {
  const [prefixLength, setPrefixLength] = useState(0);
  const [nameText, setNameText] = useState("");
  const longestName = name ?? PLACEHOLDER_NAMES.reduce((a, b) => (b.length > a.length ? b : a));

  // Users who enabled "reduce motion" in their OS get the text instantly.
  const isStatic = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  useEffect(() => {
    if (isStatic) {
      setPrefixLength(PREFIX.length);
      setNameText(name ?? PLACEHOLDER_NAMES[0]);
      return;
    }

    let timer = 0;
    const after = (ms: number, step: () => void) => {
      timer = window.setTimeout(step, ms);
    };

    const deleteName = (word: string, count: number, index: number) => {
      setNameText(word.slice(0, count));
      if (count > 0) {
        after(DELETE_DELAY, () => deleteName(word, count - 1, index));
      } else {
        after(NEXT_NAME_DELAY, () => typeName((index + 1) % PLACEHOLDER_NAMES.length, 1));
      }
    };

    const typeName = (index: number, count: number) => {
      const word = name ?? PLACEHOLDER_NAMES[index];
      setNameText(word.slice(0, count));
      if (count < word.length) {
        after(typingDelay(), () => typeName(index, count + 1));
      } else if (!name) {
        after(HOLD_DELAY, () => deleteName(word, word.length - 1, index));
      }
    };

    const typePrefix = (count: number) => {
      setPrefixLength(count);
      if (count < PREFIX.length) {
        const pause = PREFIX[count - 1] === "," ? COMMA_PAUSE : 0;
        after(typingDelay() + pause, () => typePrefix(count + 1));
      } else {
        after(typingDelay(), () => typeName(0, 1));
      }
    };

    setPrefixLength(0);
    setNameText("");
    after(START_DELAY, () => typePrefix(1));

    return () => window.clearTimeout(timer);
  }, [name, isStatic]);

  const label = name ? `${PREFIX}${name}` : PREFIX.replace(",", "").trim();

  return (
    <p className={`greeting${isStatic ? " is-static" : ""}`}>
      <span className="sr-only">{label}</span>
      {/* Invisible copy with the longest name reserves the width, so the items next to it don't shift while typing. */}
      <span className="greeting-ghost" aria-hidden="true">
        {PREFIX}
        {longestName}
        <span className="greeting-cursor" />
      </span>
      <span className="greeting-live" aria-hidden="true">
        {PREFIX.slice(0, prefixLength)}
        {nameText}
        <span className="greeting-cursor" />
      </span>
    </p>
  );
}
