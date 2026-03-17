document.querySelectorAll("span").forEach((span, i) => {
  span.style.animationDelay = -(i) + "s";
});