import React, { useEffect, useState } from 'react';
import axios from 'axios';

function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState('');
  const [editId, setEditId] = useState(null);

  const fetchTasks = async () => {
    const res = await axios.get('/api/tasks');
    setTasks(res.data);
  };

  const handleAddOrUpdate = async () => {
    if (editId) {
      await axios.put(`/api/tasks/${editId}`, { title });
      setEditId(null);
    } else {
      await axios.post('/api/tasks', { title });
    }
    setTitle('');
    fetchTasks();
  };

  const handleEdit = (task) => {
    setTitle(task.title);
    setEditId(task.id);
  };

  const handleDelete = async (id) => {
    await axios.delete(`/api/tasks/${id}`);
    fetchTasks();
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  return (
    <div style={{ margin: 20 }}>
      <h2>Task Manager</h2>
      <input
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Enter task title"
      />
      <button onClick={handleAddOrUpdate}>{editId ? 'Update' : 'Add'}</button>
      <ul>
        {tasks.map((t) => (
          <li key={t.id}>
            {t.title}{' '}
            <button onClick={() => handleEdit(t)}>Edit</button>{' '}
            <button onClick={() => handleDelete(t.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
