const buttonAdd = document.getElementById('button-add');
const list = document.getElementById('list');
const selectDestinations = document.getElementById('select-destinations');
const selectPackages = document.getElementById('select-packages');
const selectPieces = document.getElementById('select-pieces');


//add button event listener
buttonAdd.addEventListener('click', function() {
  // Get selected values from dropdowns
  const numDestinations = selectDestinations.selectedIndex; // Get the index of the selected option
  const getDestination = selectDestinations.options[numDestinations].text; // Get the text of the selected option

  const numPackages = selectPackages.selectedIndex;
  const getPackage = selectPackages.options[numPackages].text;

  const numPieces = selectPieces.selectedIndex;
  const getPiece = selectPieces.options[numPieces].text;

  const text = `${getDestination} - ${getPackage} - ${getPiece}`; // 並べたい順で１つの文字列にする

  // Create a new list item and append it to the list
  const newList = document.createElement('li');
  const labelSpan = document.createElement('span');
    labelSpan.textContent = text; //spanにtextを入れる=labelSpan内のtext以外には取消線が入らないようにするため
  // Create delete button
  const deleteButton = document.createElement('button');
  deleteButton.textContent = '削除';
  deleteButton.addEventListener('click', function() {
    list.removeChild(newList);
  });
  // create done button
  const doneButton = document.createElement('button');
  doneButton.textContent = '完了';
  doneButton.addEventListener('click', function() {
    labelSpan.style.textDecoration = 'line-through';

  // create timestamp
  const timeStamp = document.createElement('span');
    timeStamp.textContent = ` (${new Date().toLocaleString()})`;
    newList.appendChild(timeStamp);
  });

  // newList.appendChild(label);
  list.appendChild(newList);
  newList.appendChild(labelSpan);
  newList.appendChild(deleteButton);
  newList.appendChild(doneButton);
});

// // 👇👇 ここからRailsのDBデータを取得する処理 👇👇
// fetch('/deliveries')
//   .then(response => response.json())
//   .then(data => {
//     console.log(data); // DBの値が出たらRails連携OK！

//     // 例：DBの値を初期リストに表示したい場合
//     data.forEach(item => {
//       const li = document.createElement('li');
//       li.textContent = `${item.destination} - ${item.package} - ${item.pieces}`;
//       list.appendChild(li);
//     });
//   })
//   .catch(error => console.error('Fetch error:', error));