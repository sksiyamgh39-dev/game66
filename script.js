// কাজের ডামি ডেটা
const jobs = [
    { id: 1, title: "ইউটিউব ভিডিও দেখতে হবে এবং সাবস্ক্রাইব করতে হবে", reward: 5.00, employer: "Admin" },
    { id: 2, title: "ফেসবুক পেজে লাইক ও শেয়ার করুন", reward: 3.50, employer: "Tanvir" },
    { id: 3, title: "একটি ওয়েবসাইটে সাইন আপ করুন (রেফার ছাড়া)", reward: 15.00, employer: "Rahim" }
];

let userBalance = 0.00;

function loadJobs() {
    const jobListContainer = document.getElementById("job-list");
    if (!jobListContainer) return;

    jobListContainer.innerHTML = "";

    jobs.forEach(job => {
        const jobCard = document.createElement("div");
        jobCard.classList.add("job-card");

        jobCard.innerHTML = `
            <div class="job-info">
                <h3>${job.title}</h3>
                <p>পোস্টকারী: ${job.employer}</p>
            </div>
            <div>
                <div class="job-price">${job.reward.toFixed(2)} ৳</div>
                <button class="btn-apply" onclick="completeJob(${job.reward})">কাজ সম্পন্ন করুন</button>
            </div>
        `;
        jobListContainer.appendChild(jobCard);
    });
}

function completeJob(reward) {
    userBalance += reward;
    const balanceElement = document.getElementById("balance");
    if(balanceElement) {
        balanceElement.innerText = userBalance.toFixed(2);
    }
    alert(`অভিনন্দন! আপনি সফলভাবে কাজটি সম্পন্ন করেছেন এবং ${reward} টাকা অর্জন করেছেন।`);
}

document.addEventListener("DOMContentLoaded", loadJobs);
