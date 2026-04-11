const si = require('systeminformation');

async function getStats() {
    const mem = await si.mem();
    const cpu = await si.currentLoad();
    const disk = await si.fsSize();

    return {
        ram: {
            total: (mem.total / 1024 / 1024).toFixed(0),
            used: (mem.used / 1024 / 1024).toFixed(0),
            percent: mem.active / mem.total * 100
        },
        cpu: cpu.currentLoad.toFixed(2),
        disk: {
            total: disk[0].size,
            used: disk[0].used,
            percent: disk[0].use
        }
    };
}

module.exports = { getStats };