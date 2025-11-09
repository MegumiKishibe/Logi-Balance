document.addEventListener("turbo:load", () => {
  const buttonAdd = document.getElementById('button-add');
  const list = document.getElementById('list');
  const selectDestinations = document.getElementById('select-destinations');
  const selectPackages = document.getElementById('select-packages');
  const selectPieces = document.getElementById('select-pieces');

  // add button event listener
  if (buttonAdd) {
    buttonAdd.addEventListener('click', function(event) {
      event.preventDefault();  // フォーム送信防止

      // Get selected values
      const numDestinations = selectDestinations.selectedIndex;
      const getDestination = selectDestinations.options[numDestinations].text;
      const destinationId = selectDestinations.value; // ← ★追加（重要）

      const numPackages = selectPackages.value;
      const numPieces = selectPieces.value;

      const text = `${getDestination} - ${numPackages}件 - ${numPieces}個`;

      // --- Create API request (POST) ---
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
        .then((response) => response.json())
        .then((data) => {
          // --- 成功後：リストに追加 ---
          const newList = document.createElement('li');
          newList.dataset.id = data.id; // ← Railsから返ったidを設定

          const labelSpan = document.createElement('span');
          labelSpan.textContent = text;

          // Delete button
          const deleteButton = document.createElement('button');
          deleteButton.type = 'button';
          deleteButton.textContent = '削除';
          deleteButton.addEventListener('click', function() {
            list.removeChild(newList);
          });

          // Done button
          const doneButton = document.createElement('button');
          doneButton.type = 'button';
          doneButton.textContent = '完了';
          doneButton.addEventListener('click', function() {
            labelSpan.style.textDecoration = 'line-through';
            const timeStamp = document.createElement('span');
            timeStamp.textContent = ` (${new Date().toLocaleString()})`;
            newList.appendChild(timeStamp);

            // Send PATCH request to server
            const deliveryStopId = newList.dataset.id;
            if (!deliveryStopId) {
              console.warn("deliveryStopIdが設定されていません");
              return;
            }

            fetch(`/delivery_stops/${deliveryStopId}/complete`, {
              method: "PATCH",
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
              },
            })
              .then(response => {
                if (response.ok) {
                  console.log("完了処理がサーバーに送信されました！");
                } else {
                  console.error("サーバーでエラーが発生しました。");
                }
              })
              .catch(error => console.error("通信エラー:", error));
          });

          // Append everything
          list.appendChild(newList);
          newList.appendChild(labelSpan);
          newList.appendChild(deleteButton);
          newList.appendChild(doneButton);
        })
        .catch((error) => console.error("登録エラー:", error));
    });
  }
});
