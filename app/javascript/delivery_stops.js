console.log("🔥 delivery_stops.js loaded!");
document.addEventListener("DOMContentLoaded", () => {
  console.log("📛 DOMContentLoaded fired — Turboなし！");

  const buttonAdd = document.getElementById("button-add");
  const list = document.getElementById("list");
  const selectDestinations = document.getElementById("select-destinations");
  const selectPackages = document.getElementById("select-packages");
  const selectPieces = document.getElementById("select-pieces");

  if (!buttonAdd) return;

  // Remove previous event listeners caused by Turbo cache
  buttonAdd.replaceWith(buttonAdd.cloneNode(true));
  const newButtonAdd = document.getElementById("button-add");

  // ------------------------------------
  // Add button click handler
  // ------------------------------------
  newButtonAdd.addEventListener("click", (event) => {
    event.preventDefault();

    const destinationName =
      selectDestinations.options[selectDestinations.selectedIndex].text;
    const destinationId = selectDestinations.value;

    const numPackages = selectPackages.value;
    const numPieces = selectPieces.value;

    const text = `${destinationName} - ${numPackages}件 - ${numPieces}個`;

    // Create new DeliveryStop (POST)
    fetch(`/deliveries/${window.currentDeliveryId}/delivery_stops`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({
        delivery_stop: {
          delivery_id: window.currentDeliveryId,
          destination_id: destinationId,
          packages_count: numPackages,
          pieces_count: numPieces,
        },
      }),
    })
      .then((res) => res.json())
      .then((data) => {
        const li = document.createElement("li");
        li.dataset.id = data.id;

        const labelSpan = document.createElement("span");
        labelSpan.textContent = text;

        // ----------------------
        // Delete button
        //------------------------
        const deleteButton = document.createElement("button");
        deleteButton.type = "button";
        deleteButton.textContent = "削除";

        deleteButton.setAttribute("data-turbo", "false");
        deleteButton.setAttribute("data-turbo-stream", "false");

        deleteButton.addEventListener("click", () => {
          if (!confirm("本当に削除しますか？")) return;

          fetch(`/delivery_stops/${data.id}`, {
            method: "DELETE",
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector("[name='csrf-token']")
                .content,
            },
          }).then((response) => {
            if (response.ok) li.remove();
          });
        });

        // ----------------------
        // Complete button
        //------------------------
        const doneButton = document.createElement("button");
        doneButton.type = "button";
        doneButton.textContent = "完了";

        doneButton.setAttribute("data-turbo", "false");
        doneButton.setAttribute("data-turbo-stream", "false");

        doneButton.addEventListener("click", (event) => {
          event.preventDefault();
          event.stopPropagation();

          if (!confirm("この荷物を完了にしますか？")) return;

          fetch(`/delivery_stops/${data.id}/complete`, {
            method: "PATCH",
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector("[name='csrf-token']")
                .content,
              "Accept": "application/json", // disable Turbo
              "X-Requested-With": "XMLHttpRequest",
            },
          }).then((response) => {
            if (response.ok) {
              labelSpan.style.textDecoration = "line-through";
              doneButton.textContent = "完了済み";
              doneButton.disabled = true;
            }
          });
        });

        // Append all
// Append all elements
        list.appendChild(li);
        li.appendChild(labelSpan);
        li.appendChild(deleteButton);
        li.appendChild(doneButton);
      });
  });

  // ------------------------------------
  // Add Complete/Delete to existing items
  // ------------------------------------
  document.querySelectorAll("#list li").forEach((li) => {
    if (li.dataset.enhanced === "true") return;
    li.dataset.enhanced = "true";

    const id = li.dataset.id;
    if (!id) return;

    const textSpan = li.querySelector("span") || li;

    // Complete button
    const doneButton = document.createElement("button");
    doneButton.type = "button";
    doneButton.textContent = "完了";

    doneButton.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();

      if (!confirm("この荷物を完了にしますか？")) return;

      fetch(`/delivery_stops/${id}/complete`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest",
        },
      }).then((res) => {
        if (res.ok) {
          textSpan.style.textDecoration = "line-through";
          doneButton.textContent = "完了済み";
          doneButton.disabled = true;
        }
      });
    });

    // Delete button
    const deleteButton = document.createElement("button");
    deleteButton.type = "button";
    deleteButton.textContent = "削除";

    deleteButton.addEventListener("click", () => {
      if (!confirm("本当に削除しますか？")) return;

      fetch(`/delivery_stops/${id}`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        },
      }).then((res) => {
        if (res.ok) li.remove();
      });
    });

    li.appendChild(doneButton);
    li.appendChild(deleteButton);
  });
});