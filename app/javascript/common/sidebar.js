document.addEventListener("turbo:load", () => {
  const sidebar = document.querySelector(".sidebar");
  const toggleButton = document.getElementById("sidebar-toggle");

  if (toggleButton && sidebar) {
    toggleButton.addEventListener("click", () => {
      sidebar.classList.toggle("open");
    });
  }

  // active状態を自動でハイライト（URL一致）
  const links = document.querySelectorAll(".sidebar-menu a");
  links.forEach(link => {
    if (link.href === window.location.href) {
      link.parentElement.classList.add("active");
    }
  });
});
