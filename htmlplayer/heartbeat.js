// heartbeat.js
const tasks = new Map();

function hzToMs(hz) {
  if (hz <= 0) throw new Error("Frequency must be greater than 0 Hz");
  return 1000 / hz;
}

function add(id, hz, callback) {
  if (tasks.has(id)) {
    throw new Error(`Task with id "${id}" already exists.`);
  }

  const interval = setInterval(callback, hzToMs(hz));
  tasks.set(id, { hz, callback, intervalId: interval });
}

function remove(id) {
  const task = tasks.get(id);
  if (!task) return;
  clearInterval(task.intervalId);
  tasks.delete(id);
}

function update(id, newHz) {
  const task = tasks.get(id);
  if (!task) {
    throw new Error(`No task with id "${id}" to update.`);
  }

  clearInterval(task.intervalId);
  const newInterval = setInterval(task.callback, hzToMs(newHz));
  tasks.set(id, { ...task, hz: newHz, intervalId: newInterval });
}

function removeAll() {
  for (const [id, task] of tasks.entries()) {
    clearInterval(task.intervalId);
    tasks.delete(id);
  }
}

function list() {
  return Array.from(tasks.entries()).map(([id, task]) => ({
    id,
    hz: task.hz
  }));
}

// Export functions
export { add, remove, update, removeAll, list };
