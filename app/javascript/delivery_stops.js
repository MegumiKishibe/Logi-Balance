console.log("🔥 delivery_stops.js loaded!");

document.addEventListener("DOMContentLoaded", () => {
  console.log("📛 DOMContentLoaded fired");

  // --------------------------
  // Elements
  // --------------------------
  const buttonAdd = document.getElementById("button-add");
  const list = document.getElementById("list");
  const selectDestinations = document.getElementById("select-destinations");
  const inputPackages = document.getElementById("select-packages"); // number_field
  const inputPieces = document.getElementById("select-pieces"); // number_field

  // delivery id (from window.currentDeliveryId OR hidden field)
  const deliveryId =
    window.currentDeliveryId || document.getElementById("delivery-id")?.value;

  const csrfToken = document.querySelector("[name='csrf-token']")?.content;

  if (
    !buttonAdd ||
    !list ||
    !selectDestinations ||
    !inputPackages ||
    !inputPieces
  ) {
    console.warn("delivery_stops.js: required elements not found. stop.");
    return;
  }

  if (!deliveryId) {
    console.warn("delivery_stops.js: deliveryId not found. stop.");
    return;
  }

  if (!csrfToken) {
    console.warn("delivery_stops.js: CSRF token not found. stop.");
    return;
  }

  // --------------------------
  // Helpers
  // --------------------------
  const formatCompletedAt = (value) => {
    if (!value) return "";

    // すでに "YYYY/MM/DD HH:MM" みたいな整形文字列ならそのまま
    if (typeof value === "string" && !value.includes("T")) {
      return value;
    }

    // ISOなら Date にして整形
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return String(value);

    return d.toLocaleString("ja-JP", {
      timeZone: "Asia/Tokyo",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  // --------------------------
  // 既存li（ERB描画済み）にイベント付与
  // --------------------------
  const enhanceListItem = (li) => {
    if (!li) return;
    if (li.dataset.enhanced === "true") return;
    li.dataset.enhanced = "true";

    const id = li.dataset.id;
    if (!id) {
      console.warn("li has no data-id:", li);
      return;
    }

    const textSpan = li.querySelector("span");
    const deleteBtn = li.querySelector(".delete-btn");
    const doneBtn = li.querySelector(".done-btn");

    // ---- Delete ----
    if (deleteBtn) {
      deleteBtn.type = "button";
      deleteBtn.setAttribute("data-turbo", "false");

      deleteBtn.addEventListener("click", async (event) => {
        event.preventDefault();

        if (!confirm("本当に削除しますか？")) return;

        try {
          const res = await fetch(`/delivery_stops/${id}`, {
            method: "DELETE",
            headers: {
              "X-CSRF-Token": csrfToken,
              "Accept": "application/json",
              "X-Requested-With": "XMLHttpRequest",
            },
          });

          if (!res.ok) {
            console.error("DELETE failed:", res.status);
            alert("削除に失敗しました。もう一度お試しください。");
            return;
          }

          li.remove();
        } catch (e) {
          console.error(e);
          alert("通信エラーで削除できませんでした。");
        }
      });
    }

    // ---- Complete ----
    if (doneBtn) {
      doneBtn.type = "button";
      doneBtn.setAttribute("data-turbo", "false");

      doneBtn.addEventListener("click", async (event) => {
        event.preventDefault();

        if (!confirm("この荷物を完了にしますか？")) return;

        try {
          const res = await fetch(`/delivery_stops/${id}/complete`, {
            method: "PATCH",
            headers: {
              "X-CSRF-Token": csrfToken,
              "Accept": "application/json",
              "X-Requested-With": "XMLHttpRequest",
            },
          });

          if (!res.ok) {
            console.error("PATCH complete failed:", res.status);
            alert("完了にできませんでした。もう一度お試しください。");
            return;
          }

          const data = await res.json().catch(() => ({}));

          // UI update
          if (textSpan) textSpan.style.textDecoration = "line-through";
          doneBtn.textContent = "完了済み";
          doneBtn.disabled = true;

          // timestamp（重複防止）: textSpan の直後に表示（見えやすい）
          if (!li.querySelector(".done-at")) {
            const ts = document.createElement("span");
            ts.className = "done-at";
            ts.style.marginLeft = "8px";

            const completedAtText = formatCompletedAt(data?.completed_at);
            ts.textContent = completedAtText ? `（${completedAtText}）` : "";

            if (textSpan) {
              textSpan.insertAdjacentElement("afterend", ts);
            } else {
              li.appendChild(ts);
            }
          }
        } catch (e) {
          console.error(e);
          alert("通信エラーで完了にできませんでした。");
        }
      });
    }
  };

  // --------------------------
  // JSで新規liを作る（新規追加分のみ）
  // --------------------------
  const buildListItem = ({ id, labelText }) => {
    const li = document.createElement("li");
    li.dataset.id = String(id);

    const span = document.createElement("span");
    span.textContent = labelText;

    const deleteBtn = document.createElement("button");
    deleteBtn.className = "delete-btn";
    deleteBtn.textContent = "削除";
    deleteBtn.type = "button";
    deleteBtn.setAttribute("data-turbo", "false");

    const doneBtn = document.createElement("button");
    doneBtn.className = "done-btn";
    doneBtn.textContent = "完了";
    doneBtn.type = "button";
    doneBtn.setAttribute("data-turbo", "false");

    li.appendChild(span);
    li.appendChild(deleteBtn);
    li.appendChild(doneBtn);

    // イベント付与（増殖なし）
    enhanceListItem(li);

    return li;
  };

  // --------------------------
  // 1) Enhance existing items (ERB rendered)
  // --------------------------
  document.querySelectorAll("#list li").forEach((li) => enhanceListItem(li));

  // --------------------------
  // 2) Add button (POST create)
  // --------------------------
  // 二重bind防止（clone）
  buttonAdd.replaceWith(buttonAdd.cloneNode(true));
  const newButtonAdd = document.getElementById("button-add");

  newButtonAdd.addEventListener("click", async (event) => {
    event.preventDefault();

    const destinationId = selectDestinations.value;
    const destinationName =
      selectDestinations.options[selectDestinations.selectedIndex]?.text;

    const packages = inputPackages.value;
    const pieces = inputPieces.value;

    if (!destinationId) {
      alert("配達先を選択してください");
      return;
    }
    if (!packages || Number(packages) <= 0) {
      alert("件数を入力してください");
      return;
    }
    if (!pieces || Number(pieces) <= 0) {
      alert("個数を入力してください");
      return;
    }

    const labelText = `${destinationName}：${packages}件／${pieces}個`;

    try {
      const res = await fetch(`/deliveries/${deliveryId}/delivery_stops`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest",
        },
        body: JSON.stringify({
          delivery_stop: {
            destination_id: destinationId,
            packages_count: packages,
            pieces_count: pieces,
          },
        }),
      });

      if (!res.ok) {
        console.error("POST failed:", res.status);
        alert("追加に失敗しました。入力内容を確認してください。");
        return;
      }

      const data = await res.json().catch(() => ({})); // { id: ... } を想定
      if (!data?.id) {
        console.error("POST response has no id:", data);
        alert("追加に失敗しました（レスポンス不正）");
        return;
      }

      const li = buildListItem({ id: data.id, labelText });
      list.appendChild(li);

      // 入力リセット
      inputPackages.value = "";
      inputPieces.value = "";
      selectDestinations.selectedIndex = 0;
    } catch (e) {
      console.error(e);
      alert("通信エラーで追加できませんでした。");
    }
  });
});
