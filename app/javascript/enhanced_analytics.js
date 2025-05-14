// Enhanced Analytics for Virtual Job Fair Platform
document.addEventListener('turbo:load', function() {
  // Only initialize charts if we're on an analytics page
  if (document.querySelector('.analytics-dashboard')) {
    initializeCharts();
  }
});

function initializeCharts() {
  // Skills Distribution Chart (for students)
  const skillsChartCanvas = document.getElementById('skills-distribution-chart');
  if (skillsChartCanvas) {
    const skillsData = JSON.parse(skillsChartCanvas.dataset.skills);
    new Chart(skillsChartCanvas, {
      type: 'bar',
      data: {
        labels: skillsData.labels,
        datasets: [{
          label: 'Students with Skill',
          data: skillsData.values,
          backgroundColor: 'rgba(59, 130, 246, 0.5)',
          borderColor: 'rgb(59, 130, 246)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: true,
            text: 'Top Skills Distribution'
          }
        }
      }
    });
  }

  // Education Timeline Chart (for students)
  const educationChartCanvas = document.getElementById('education-timeline-chart');
  if (educationChartCanvas) {
    const educationData = JSON.parse(educationChartCanvas.dataset.education);
    new Chart(educationChartCanvas, {
      type: 'line',
      data: {
        labels: educationData.labels,
        datasets: [{
          label: 'Graduation Count',
          data: educationData.values,
          fill: false,
          borderColor: 'rgb(75, 192, 192)',
          tension: 0.1
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        }
      }
    });
  }

  // Industry Distribution Chart (for recruiters)
  const industryChartCanvas = document.getElementById('industry-distribution-chart');
  if (industryChartCanvas) {
    const industryData = JSON.parse(industryChartCanvas.dataset.industries);
    new Chart(industryChartCanvas, {
      type: 'pie',
      data: {
        labels: industryData.labels,
        datasets: [{
          data: industryData.values,
          backgroundColor: [
            'rgba(255, 99, 132, 0.6)',
            'rgba(54, 162, 235, 0.6)',
            'rgba(255, 206, 86, 0.6)',
            'rgba(75, 192, 192, 0.6)',
            'rgba(153, 102, 255, 0.6)',
            'rgba(255, 159, 64, 0.6)',
            'rgba(199, 199, 199, 0.6)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'right',
          }
        }
      }
    });
  }

  // Career Officer Dashboard - Student Status Chart
  const statusChartCanvas = document.getElementById('student-status-chart');
  if (statusChartCanvas) {
    const statusData = JSON.parse(statusChartCanvas.dataset.status);
    new Chart(statusChartCanvas, {
      type: 'doughnut',
      data: {
        labels: statusData.labels,
        datasets: [{
          data: statusData.values,
          backgroundColor: [
            'rgba(34, 197, 94, 0.6)',
            'rgba(234, 179, 8, 0.6)',
            'rgba(59, 130, 246, 0.6)',
            'rgba(99, 102, 241, 0.6)',
            'rgba(168, 85, 247, 0.6)',
            'rgba(239, 68, 68, 0.6)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'right',
          }
        }
      }
    });
  }

  // Profile Completion Trends (Career Officer View)
  const completionTrendsCanvas = document.getElementById('completion-trends-chart');
  if (completionTrendsCanvas) {
    const trendsData = JSON.parse(completionTrendsCanvas.dataset.trends);
    new Chart(completionTrendsCanvas, {
      type: 'bar',
      data: {
        labels: ['0-25%', '26-50%', '51-75%', '76-100%'],
        datasets: [
          {
            label: 'Students',
            data: trendsData.students,
            backgroundColor: 'rgba(59, 130, 246, 0.6)',
            borderColor: 'rgb(59, 130, 246)',
            borderWidth: 1
          },
          {
            label: 'Recruiters',
            data: trendsData.recruiters,
            backgroundColor: 'rgba(234, 88, 12, 0.6)',
            borderColor: 'rgb(234, 88, 12)',
            borderWidth: 1
          }
        ]
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0
            }
          }
        },
        plugins: {
          title: {
            display: true,
            text: 'Profile Completion Distribution'
          }
        }
      }
    });
  }
} 