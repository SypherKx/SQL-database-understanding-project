// Database instance & state
let db = null;
let currentChart = null;

// Preset analytical queries map with human explanations
const PRESET_QUERIES = {
    1: {
        title: "Report 1: Executive Revenue & Month-over-Month Growth (INR)",
        desc: "This query calculates total monthly revenue and Month-over-Month (MoM) growth percentage using the SQL LAG() window function. It helps business executives track sales momentum across Indian quarters.",
        technique: "Technique: CTE + Window Function LAG()",
        sql: `WITH MonthlyMetrics AS (
    SELECT
        STRFTIME('%Y-%m', order_date) AS order_month,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT user_id) AS unique_buyers,
        SUM(total_amount) AS monthly_revenue_inr,
        ROUND(AVG(total_amount), 2) AS avg_order_value_inr
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY STRFTIME('%Y-%m', order_date)
)
SELECT
    order_month,
    total_orders,
    unique_buyers,
    monthly_revenue_inr,
    avg_order_value_inr,
    COALESCE(LAG(monthly_revenue_inr) OVER (ORDER BY order_month), 0) AS prev_month_revenue_inr,
    ROUND(
        COALESCE((monthly_revenue_inr - LAG(monthly_revenue_inr) OVER (ORDER BY order_month)) 
        / NULLIF(LAG(monthly_revenue_inr) OVER (ORDER BY order_month), 0) * 100, 0), 2
    ) AS mom_growth_pct
FROM MonthlyMetrics
ORDER BY order_month ASC;`,
        chartType: 'bar',
        labelCol: 'order_month',
        valCol: 'monthly_revenue_inr'
    },
    2: {
        title: "Report 2: Customer RFM Segmentation (Recency, Frequency, Monetary)",
        desc: "This report segments customers into VIP Champions, Loyalists, and At-Risk groups using NTILE(4) statistical quartiles based on how recently they purchased, how frequently they order, and total INR spent.",
        technique: "Technique: NTILE(4) Quartile Window Function + CASE",
        sql: `WITH BaseRFM AS (
    SELECT
        u.user_id,
        u.full_name,
        u.city,
        CAST(JULIANDAY('2024-02-15') - JULIANDAY(MAX(o.order_date)) AS INT) AS recency_days,
        COUNT(o.order_id) AS frequency,
        SUM(o.total_amount) AS monetary_val_inr
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.order_status = 'Completed'
    GROUP BY u.user_id, u.full_name, u.city
),
RFMScores AS (
    SELECT
        user_id,
        full_name,
        city,
        recency_days,
        frequency,
        monetary_val_inr,
        NTILE(4) OVER (ORDER BY recency_days ASC) AS R_Score,
        NTILE(4) OVER (ORDER BY frequency DESC) AS F_Score,
        NTILE(4) OVER (ORDER BY monetary_val_inr DESC) AS M_Score
    FROM BaseRFM
)
SELECT
    full_name,
    city,
    recency_days,
    frequency,
    monetary_val_inr,
    (R_Score || F_Score || M_Score) AS rfm_code,
    CASE 
        WHEN R_Score = 4 AND F_Score = 4 AND M_Score = 4 THEN 'VIP Champion'
        WHEN F_Score >= 3 AND M_Score >= 3 THEN 'Loyal Customer'
        WHEN R_Score <= 2 AND F_Score >= 3 THEN 'At Risk'
        ELSE 'Potential Loyalist'
    END AS customer_segment
FROM RFMScores
ORDER BY monetary_val_inr DESC;`,
        chartType: 'doughnut',
        labelCol: 'customer_segment',
        valCol: 'monetary_val_inr'
    },
    3: {
        title: "Report 3: Pareto 80/20 Revenue Product Drivers",
        desc: "Applies Pareto's 80/20 principle using running cumulative SUM() OVER () window logic to isolate top revenue-generating products from lower-performing items.",
        technique: "Technique: Cumulative SUM() OVER (ORDER BY ...)",
        sql: `WITH ProductPerformance AS (
    SELECT
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS gross_revenue_inr,
        SUM(oi.quantity * (oi.unit_price - p.cost_price)) AS total_profit_inr
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name
),
CumulativeTotals AS (
    SELECT
        product_name,
        gross_revenue_inr,
        total_profit_inr,
        SUM(gross_revenue_inr) OVER () AS overall_revenue_inr,
        SUM(gross_revenue_inr) OVER (ORDER BY gross_revenue_inr DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue_inr
    FROM ProductPerformance
)
SELECT
    product_name,
    gross_revenue_inr,
    total_profit_inr,
    ROUND((running_revenue_inr / overall_revenue_inr) * 100, 2) AS cumulative_revenue_pct,
    CASE 
        WHEN (running_revenue_inr / overall_revenue_inr) <= 0.80 THEN 'Top 80% Driver'
        ELSE 'Tail Product'
    END AS classification
FROM CumulativeTotals
ORDER BY gross_revenue_inr DESC;`,
        chartType: 'bar',
        labelCol: 'product_name',
        valCol: 'gross_revenue_inr'
    },
    4: {
        title: "Report 4: Rolling 7-Day Revenue Trend (₹)",
        desc: "Calculates a 7-day centered moving average using window frame specifications (ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) to smooth daily sales volatility.",
        technique: "Technique: Window Framing (ROWS PRECEDING)",
        sql: `WITH DailySales AS (
    SELECT
        DATE(order_date) AS sales_date,
        SUM(total_amount) AS daily_revenue_inr
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE(order_date)
)
SELECT
    sales_date,
    daily_revenue_inr,
    ROUND(
        AVG(daily_revenue_inr) OVER (
            ORDER BY sales_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_7day_avg_inr
FROM DailySales
ORDER BY sales_date ASC;`,
        chartType: 'line',
        labelCol: 'sales_date',
        valCol: 'rolling_7day_avg_inr'
    },
    5: {
        title: "Report 5: Fulfillment Center Stock & Reorder Risk",
        desc: "Monitors warehouse inventory across Indian fulfillment centers (Bengaluru, Bhiwandi Mumbai, Gurugram NCR) and calculates stock coverage ratios to trigger automated restock warnings.",
        technique: "Technique: Multi-table JOIN + Ratio CASE",
        sql: `SELECT
    p.product_name,
    i.fulfillment_center,
    i.quantity_in_stock,
    p.reorder_level,
    CASE 
        WHEN i.quantity_in_stock = 0 THEN 'OUT OF STOCK'
        WHEN i.quantity_in_stock <= (p.reorder_level * 0.5) THEN 'HIGH RISK'
        WHEN i.quantity_in_stock <= p.reorder_level THEN 'REORDER NEEDED'
        ELSE 'OPTIMAL'
    END AS restock_priority
FROM inventory i
JOIN products p ON i.product_id = p.product_id
ORDER BY i.quantity_in_stock ASC;`,
        chartType: 'bar',
        labelCol: 'product_name',
        valCol: 'quantity_in_stock'
    },
    6: {
        title: "Report 6: Indian Payment Gateway Reliability & Failure Rates",
        desc: "Evaluates uptime performance across Razorpay, PhonePe, CRED Pay, Google Pay, and Net Banking to measure payment failure rates and prevent checkout revenue leakage.",
        technique: "Technique: Conditional Aggregation (SUM CASE)",
        sql: `SELECT
    gateway,
    COUNT(payment_id) AS total_transactions,
    SUM(CASE WHEN payment_status = 'Success' THEN 1 ELSE 0 END) AS success_count,
    SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END) AS failure_count,
    ROUND(
        SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(payment_id), 2
    ) AS failure_rate_pct
FROM payments
GROUP BY gateway;`,
        chartType: 'pie',
        labelCol: 'gateway',
        valCol: 'total_transactions'
    },
    7: {
        title: "Report 7: Metro City ARPU (Average Revenue Per User)",
        desc: "Aggregates revenue and order volume by major Indian metro cities (Bengaluru, Mumbai, Delhi NCR, Hyderabad, Pune, Chennai) to compute Average Revenue Per User (ARPU).",
        technique: "Technique: Multi-level Aggregation & ARPU Metric",
        sql: `SELECT
    u.city,
    u.state,
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue_inr,
    ROUND(COALESCE(SUM(o.total_amount), 0) / COUNT(DISTINCT u.user_id), 2) AS arpu_inr
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.order_status = 'Completed'
GROUP BY u.city, u.state
ORDER BY total_revenue_inr DESC;`,
        chartType: 'bar',
        labelCol: 'city',
        valCol: 'total_revenue_inr'
    }
};

// Initialize Database
async function initDatabase() {
    try {
        const sqlPromise = initSqlJs({
            locateFile: file => `https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/${file}`
        });
        const SQL = await sqlPromise;
        db = new SQL.Database();

        const schemaRes = await fetch('01_schema.sql');
        const schemaSql = await schemaRes.text();
        db.run(schemaSql);

        const seedRes = await fetch('02_seed_data.sql');
        const seedSql = await seedRes.text();
        db.run(seedSql);

        console.log("Database ready!");
        loadQuery(1);
    } catch (err) {
        console.error("Init Error:", err);
    }
}

// Theme Toggle Switch Handling
function initThemeToggle() {
    const themeBtn = document.getElementById('theme-toggle-btn');
    if (!themeBtn) return;

    const savedTheme = localStorage.getItem('theme') || 'light';
    if (savedTheme === 'dark') {
        document.body.setAttribute('data-theme', 'dark');
        themeBtn.innerHTML = '<i class="fa-solid fa-sun"></i> <span>Light Mode</span>';
    }

    themeBtn.addEventListener('click', () => {
        const currentTheme = document.body.getAttribute('data-theme');
        if (currentTheme === 'dark') {
            document.body.removeAttribute('data-theme');
            localStorage.setItem('theme', 'light');
            themeBtn.innerHTML = '<i class="fa-solid fa-moon"></i> <span>Dark Mode</span>';
        } else {
            document.body.setAttribute('data-theme', 'dark');
            localStorage.setItem('theme', 'dark');
            themeBtn.innerHTML = '<i class="fa-solid fa-sun"></i> <span>Light Mode</span>';
        }
    });
}

// Load Preset Query into Dashboard
function loadQuery(queryId) {
    const queryObj = PRESET_QUERIES[queryId];
    if (!queryObj) return;

    document.getElementById('report-title').innerText = queryObj.title;
    document.getElementById('report-desc').innerText = queryObj.desc;
    document.getElementById('query-technique').innerText = queryObj.technique;
    document.getElementById('sql-editor').value = queryObj.sql;
    
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    const activeItem = document.querySelector(`.nav-item[data-query-id="${queryId}"]`);
    if (activeItem) activeItem.classList.add('active');

    executeCurrentQuery(queryObj);
}

// Execute Query
function executeCurrentQuery(queryMeta = null) {
    if (!db) return;

    const sqlText = document.getElementById('sql-editor').value;
    const startTime = performance.now();

    try {
        const res = db.exec(sqlText);
        const endTime = performance.now();
        document.getElementById('exec-time').innerHTML = `<i class="fa-solid fa-bolt"></i> Exec Time: ${(endTime - startTime).toFixed(1)}ms`;

        if (res.length > 0) {
            const columns = res[0].columns;
            const values = res[0].values;
            
            document.getElementById('row-count-badge').innerText = `${values.length} rows returned`;
            renderTable(columns, values);

            if (!queryMeta) {
                const activeNav = document.querySelector('.nav-item.active');
                if (activeNav) {
                    const qId = activeNav.getAttribute('data-query-id');
                    queryMeta = PRESET_QUERIES[qId];
                }
            }

            if (queryMeta && queryMeta.labelCol && queryMeta.valCol) {
                renderChart(columns, values, queryMeta);
            }
        } else {
            renderTable([], []);
            document.getElementById('row-count-badge').innerText = '0 rows returned';
        }
    } catch (err) {
        alert("SQL Error:\n" + err.message);
    }
}

// Render Table
function renderTable(columns, values) {
    const headRow = document.getElementById('table-head');
    const tbody = document.getElementById('table-body');
    
    headRow.innerHTML = '';
    tbody.innerHTML = '';

    columns.forEach(col => {
        const th = document.createElement('th');
        th.innerText = col;
        headRow.appendChild(th);
    });

    values.forEach(row => {
        const tr = document.createElement('tr');
        row.forEach(val => {
            const td = document.createElement('td');
            td.innerText = val !== null ? val : 'NULL';
            tr.appendChild(td);
        });
        tbody.appendChild(tr);
    });
}

// Render Chart
function renderChart(columns, values, queryMeta) {
    const labelIdx = columns.indexOf(queryMeta.labelCol);
    const valIdx = columns.indexOf(queryMeta.valCol);

    if (labelIdx === -1 || valIdx === -1) return;

    const labels = values.map(r => r[labelIdx]);
    const dataVals = values.map(r => r[valIdx]);

    const ctx = document.getElementById('analyticsChart').getContext('2d');
    
    if (currentChart) {
        currentChart.destroy();
    }

    currentChart = new Chart(ctx, {
        type: queryMeta.chartType || 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: queryMeta.title,
                data: dataVals,
                backgroundColor: [
                    '#3b82f6', '#10b981', '#8b5cf6', '#f59e0b', '#ef4444', '#06b6d4', '#ec4899'
                ],
                borderColor: '#111827',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { labels: { color: '#9ca3af', font: { family: 'Inter' } } }
            },
            scales: queryMeta.chartType === 'doughnut' || queryMeta.chartType === 'pie' ? {} : {
                x: { ticks: { color: '#9ca3af' }, grid: { color: 'rgba(255,255,255,0.05)' } },
                y: { ticks: { color: '#9ca3af' }, grid: { color: 'rgba(255,255,255,0.05)' } }
            }
        }
    });
}

// Global Event Handlers
document.addEventListener('DOMContentLoaded', () => {
    initDatabase();
    initThemeToggle();

    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', () => {
            const qId = item.getAttribute('data-query-id');
            loadQuery(qId);
        });
    });

    document.getElementById('run-btn').addEventListener('click', () => {
        executeCurrentQuery();
    });
});
