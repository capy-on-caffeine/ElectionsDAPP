const pollForm = document.getElementById("radioForm");
const resultsDiv = document.getElementById('results');
const resetButton = document.getElementById('reset');

import { poll_backend } from "../../declarations/poll_backend";

const pollResults = {
    // "Rust": 0,
    // "Motoko": 0,
    // "TypeScript": 0,
    // "Python": 0
};

document.addEventListener('DOMContentLoaded', async (e) => {
  e.preventDefault();
  const question = await poll_backend.getQuestion();
  document.getElementById("question").innerText = question;
  
  const voteCounts = await poll_backend.getVotes();
  updateLocalVoteCounts(voteCounts);
  displayResults();
  return false;
}, false);

//Event listener that listens for when the form is submitted.
//When the form is submitted with an option, it calls the backend canister
//via "await poll_backend.vote(selectedOption)"
pollForm.addEventListener('submit', async (e) => {
  //note that this is at beginning of the submit callback, this is deliberate
  //This is so the default behavior is set BEFORE the awaits are called below
  e.preventDefault(); 

  const formData = new FormData(pollForm);
  const checkedValue = formData.get("option");

  const updatedVoteCounts = await poll_backend.vote(checkedValue);
  console.log("Returning from await...")
  console.log(updatedVoteCounts);
  updateLocalVoteCounts(updatedVoteCounts);
  displayResults();
  return false;
}, false);


function reset(passkey) {
  await poll_backend.resetVotes(passkey);
  const voteCounts = await poll_backend.getVotes();
  updateLocalVoteCounts(voteCounts);
  displayResults();
};

function displayResults() {
  let resultHTML = '<ul>';
  for (let key in pollResults) {
      resultHTML += '<li><strong>' + key + '</strong>: ' + pollResults[key] + '</li>';
  }
  resultHTML += '</ul>';
  resultsDiv.innerHTML = resultHTML;
};

function updateLocalVoteCounts(arrayOfVoteArrays){

  for (let voteArray of arrayOfVoteArrays) {
    //Example voteArray -> ["Motoko","0"]
    let voteOption = voteArray[0];
    let voteCount = voteArray[1];
    pollResults[voteOption] = voteCount;
  }

};
