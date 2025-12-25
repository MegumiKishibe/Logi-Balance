console.log("🔥 delivery_stops.js loaded!");

document.addEventListener("DOMContentLoaded", () => {
  console.log("📛 DOMContentLoaded fired — Turboなし！");

  // --------------------------
  // Elements
  // --------------------------
  const buttonAdd = document.getElementById("button-add");
  const list = document.getElementById("list");
  const selectDestinations = document.getElementById("select-destinations");
  const inputPackages = document.getElementById("select-packages");
  const inputPieces = document.getElementById("select-pieces");

  const deliveryId = window.currentDeliveryId || document.getElementById("delivery-id")?.value;
  const csrfToken = document.querySelector("[name='csrf-token']")?.content;

  if (!buttonAdd || !list || !selectDestinations || !inputPackages || !inputPieces) {
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
  // Helpers (元のロジックを完全維持)
  // --------------------------
  const formatJaNow = () =>
    new Date().toLocaleString("ja-JP", {
      timeZone: "Asia/Tokyo",
      year: "numeric", month: "2-digit", day: "2-digit",
      hour: "2-digit", minute: "2-digit",
    });

  const normalizeCompletedAtText = (value) => {
    if (!value) return null;
    if (typeof value !== "string") return null;
    if (!value.includes("T")) return value;
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return value;
    return d.toLocaleString("ja-JP", {
      timeZone: "Asia/Tokyo", year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit",
    });
  };

  const insertDoneAt = (li, textSpan, completedAtText) => {
    if (li.querySelector(".done-at")) return;
    const ts = document.createElement("span");
    ts.className = "done-at";
    ts.style.marginLeft = "8px";
    ts.style.textDecoration = "none";
    const text = completedAtText || formatJaNow();
    ts.textContent = `（${text}）`;
    if (textSpan) {
      textSpan.insertAdjacentElement("afterend", ts);
    } else {
      li.appendChild(ts);
    }
  };

  // --------------------------
  // Enhance existing LI
  // --------------------------
  const enhanceListItem = (li) => {
    if (!li || li.dataset.enhanced === "true") return;
    li.dataset.enhanced = "true";

    const id = li.dataset.id;
    if (!id) return;

    const textSpan = li.querySelector("span");
    const deleteBtn = li.querySelector(".delete-btn");
    const doneBtn = li.querySelector(".done-btn");

    if (deleteBtn) {
      deleteBtn.type = "button";
      deleteBtn.setAttribute("data-turbo", "false");
      deleteBtn.addEventListener("click", async (event) => {
        event.preventDefault();
        if (!confirm("本当に削除しますか？")) return;
        try {
          const res = await fetch(`/delivery_stops/${id}`, {
            method: "DELETE",
            headers: { "X-CSRF-Token": csrfToken, "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" },
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

    if (doneBtn) {
      doneBtn.type = "button";
      doneBtn.setAttribute("data-turbo", "false");
      doneBtn.addEventListener("click", async (event) => {
        event.preventDefault();
        if (!confirm("この荷物を完了にしますか？")) return;
        try {
          const res = await fetch(`/delivery_stops/${id}/complete`, {
            method: "PATCH",
            headers: { "X-CSRF-Token": csrfToken, "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" },
          });
          if (!res.ok) {
            console.error("PATCH complete failed:", res.status);
            alert("完了にできませんでした。もう一度お試しください。");
            return;
          }
          const data = await res.json().catch(() => ({}));
          if (textSpan) textSpan.style.textDecoration = "line-through";
          doneBtn.textContent = "完了済み";
          doneBtn.disabled = true;
          const completedAtText = normalizeCompletedAtText(data?.completed_at);
          insertDoneAt(li, textSpan, completedAtText);
        } catch (e) {
          console.error(e);
          alert("通信エラーで完了にできませんでした。");
        }
      });
    }
  };

  document.querySelectorAll("#list li").forEach((li) => enhanceListItem(li));

  // --------------------------
  // Build LI (デザイン用のクラスを追加)
  // --------------------------
  const buildListItem = ({ id, labelText }) => {
    const li = document.createElement("li");
    li.dataset.id = String(id);

    const span = document.createElement("span");
    span.style.flex = "1";
    span.textContent = labelText;

    // 削除ボタン
    const deleteBtn = document.createElement("button");
    // CSSデザイン用の btn と、JS動作用の delete-btn を両方入れる
    deleteBtn.className = "btn btn-secondary delete-btn"; 
    deleteBtn.style.cssText = "padding: 4px 12px; font-size: 0.8rem; margin-left: auto;";
    deleteBtn.textContent = "削除";
    deleteBtn.type = "button";
    deleteBtn.setAttribute("data-turbo", "false");

    // 完了ボタン
    const doneBtn = document.createElement("button");
    // CSSデザイン用の btn と、JS動作用の done-btn を両方入れる
    doneBtn.className = "btn btn-primary done-btn"; 
    doneBtn.style.cssText = "padding: 4px 12px; font-size: 0.8rem; background-color: #8dbb8d;";
    doneBtn.textContent = "完了";
    doneBtn.type = "button";
    doneBtn.setAttribute("data-turbo", "false");

    li.appendChild(span);
    li.appendChild(deleteBtn);
    li.appendChild(doneBtn);

    enhanceListItem(li); // ここでイベントが登録される
    return li;
  };
  // --------------------------
  // Add button (元のクローン処理を維持)
  // --------------------------
  buttonAdd.replaceWith(buttonAdd.cloneNode(true));
  const newButtonAdd = document.getElementById("button-add");

  newButtonAdd.addEventListener("click", async (event) => {
    event.preventDefault();

    const destinationId = selectDestinations.value;
    const destinationName = selectDestinations.options[selectDestinations.selectedIndex]?.text;
    const packages = inputPackages.value;
    const pieces = inputPieces.value;

    if (!destinationId) return alert("配達先を選択してください");
    if (!packages || Number(packages) <= 0) return alert("件数を入力してください");
    if (!pieces || Number(pieces) <= 0) return alert("個数を入力してください");

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

      const data = await res.json().catch(() => ({}));
      if (!data?.id) {
        console.error("POST response has no id:", data);
        alert("追加に失敗しました（レスポンス不正）");
        return;
      }

      list.appendChild(buildListItem({ id: data.id, labelText }));

      inputPackages.value = "";
      inputPieces.value = "";
      selectDestinations.selectedIndex = 0;
    } catch (e) {
      console.error(e);
      alert("通信エラーで追加できませんでした。");
    }
  });
});