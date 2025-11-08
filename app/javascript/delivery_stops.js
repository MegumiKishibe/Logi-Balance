document.addEventListener("turbo:load", () => {
  const buttonAdd = document.getElementById('button-add');
  const list = document.getElementById('list');
  const selectDestinations = document.getElementById('select-destinations');
  const selectPackages = document.getElementById('select-packages');
  const selectPieces = document.getElementById('select-pieces');

  // add button event listener
  if (buttonAdd) {
    buttonAdd.addEventListener('click', function(event) {
      event.preventDefault();  // ✅ フォーム送信防止

      // Get selected values
      const numDestinations = selectDestinations.selectedIndex;
      const getDestination = selectDestinations.options[numDestinations].text;

      const numPackages = selectPackages.value;
      const numPieces = selectPieces.value;

      const text = `${getDestination} - ${numPackages}件 - ${numPieces}個`;

      // Create list item
      const newList = document.createElement('li');
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
      });

      // Append everything
      list.appendChild(newList);
      newList.appendChild(labelSpan);
      newList.appendChild(deleteButton);
      newList.appendChild(doneButton);
    });
  }
});
