console.log("🔥 daily_course_run_stops.js loaded!");

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

  // hidden input: <input type="hidden" id="daily-course-run-id" value="...">
  const dailyCourseRunId =
    window.currentDailyCourseRunId || document.getElementById("daily-course-run-id")?.value;

  const csrfToken = document.querySelector("[name='csrf-token']")?.content;

  if (!buttonAdd || !list || !selectDestinations || !inputPackages || !inputPieces) {
    console.warn("daily_course_run_stops.js: required elements not found. stop.");
    return;
  }
  if (!dailyCourseRunId) {
    console.warn("daily_course_run_stops.js: dailyCourseRunId not found. stop.");
    return;
  }
  if (!csrfToken) {
    console.warn("daily_course_run_stops.js: CSRF token not found. stop.");
    return;
  }

  // --------------------------
  // Helpers
  // --------------------------
  const formatJaNow = () =>
    new Date().toLocaleString("ja-JP", {
      timeZone: "Asia/Tokyo",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
    });

  const normalizeCompletedAtText = (value) => {
    if (!value) return null;
    if (typeof value !== "string") return null;

    // already formatted
    if (!value.includes("T")) return value;

    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return value;

    return d.toLocaleString("ja-JP", {
      timeZone: "Asia/Tokyo",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
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

    if (textSpan) textSpan.insertAdjacentElement("afterend", ts);
    else li.appendChild(ts);
  };

  // --------------------------
  // Enhance existing LI
  // --------------------------
  const enhanceListItem = (li) => {
    if (!li || li.dataset.enhanced === "true") return;
    li.dataset.enhanced = "true";

    const id = li.dataset.id;
    if (!id) return;

    const textSpan = li.querySelector(".stop-info") || li.querySelector("span");
    const deleteBtn = li.querySelector(".delete-btn");
    const doneBtn = li.querySelector(".done-btn");

    // DELETE: /daily_course_run_stops/:id
    if (deleteBtn) {
      deleteBtn.type = "button";
      deleteBtn.setAttribute("data-turbo", "false");
      deleteBtn.addEventListener("click", async (event) => {
        event.preventDefault();
        if (!confirm("本当に削除しますか？")) return;

        try {
          const res = await fetch(`/daily_course_run_stops/${id}`, {
            method: "DELETE",
            headers: {
              "X-CSRF-Token": csrfToken,
              Accept: "application/json",
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

    // PATCH complete: /daily_course_run_stops/:id/complete
    if (doneBtn) {
      doneBtn.type = "button";
      doneBtn.setAttribute("data-turbo", "false");
      doneBtn.addEventListener("click", async (event) => {
        event.preventDefault();
        if (!confirm("この荷物を完了にしますか？")) return;

        try {
          const res = await fetch(`/daily_course_run_stops/${id}/complete`, {
            method: "PATCH",
            headers: {
              "X-CSRF-Token": csrfToken,
              Accept: "application/json",
              "X-Requested-With": "XMLHttpRequest",
            },
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
  // Build LI
  // --------------------------
  const buildListItem = ({ id, labelText }) => {
    const li = document.createElement("li");
    li.dataset.id = String(id);

    const span = document.createElement("span");
    span.className = "stop-info";
    span.textContent = labelText;

    const btnGroup = document.createElement("div");
    btnGroup.className = "btn-group-mobile";

    const deleteBtn = document.createElement("button");
    deleteBtn.className = "btn btn-secondary delete-btn";
    deleteBtn.textContent = "削除";
    deleteBtn.type = "button";
    deleteBtn.setAttribute("data-turbo", "false");

    const doneBtn = document.createElement("button");
    doneBtn.className = "btn btn-primary done-btn";
    doneBtn.textContent = "完了";
    doneBtn.type = "button";
    doneBtn.setAttribute("data-turbo", "false");

    btnGroup.appendChild(deleteBtn);
    btnGroup.appendChild(doneBtn);

    li.appendChild(span);
    li.appendChild(btnGroup);

    enhanceListItem(li);
    return li;
  };

  // --------------------------
  // Add button
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
      // POST: /daily_course_runs/:daily_course_run_id/daily_course_run_stops
      const res = await fetch(`/daily_course_runs/${dailyCourseRunId}/daily_course_run_stops`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          Accept: "application/json",
          "X-Requested-With": "XMLHttpRequest",
        },
        body: JSON.stringify({
          daily_course_run_stop: {
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
