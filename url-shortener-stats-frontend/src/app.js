const API_URL = "https://m3hy6pczz1.execute-api.us-east-1.amazonaws.com";

async function searchStats() {
  const codigo = document.getElementById("codigo").value;

  const fecha = document.getElementById("fecha").value;

  let url = `${API_URL}/stats/${codigo}`;

  if (fecha) {
    url += `?fecha=${fecha}`;
  }

  const response = await fetch(url);

  const data = await response.json();

  renderData(data);
}

function renderData(data) {
  const results = document.getElementById("results");

  results.innerHTML = "";

  Object.entries(data).forEach(([fecha, total]) => {
    results.innerHTML += `

<div class="card">

<h3>${fecha}</h3>

<p>

Visitas: ${total}

</p>

</div>

`;
  });
}
