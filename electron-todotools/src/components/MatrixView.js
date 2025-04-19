import React, { useState, useEffect } from 'react';

const MatrixView = () => {
  // 할 일 목록 상태
  const [tasks, setTasks] = useState([]);
  // 드래그 중인 할 일 상태
  const [draggedTask, setDraggedTask] = useState(null);
  // 선택된 항목
  const [selectedTask, setSelectedTask] = useState(null);
  // 할 일 추가 모달 상태
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  // 할 일 수정 모달 상태
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  // 새 할 일 입력 상태
  const [newTaskText, setNewTaskText] = useState('');
  // 새 할 일 중요도
  const [newTaskImportance, setNewTaskImportance] = useState('high');
  // 새 할 일 긴급도
  const [newTaskUrgency, setNewTaskUrgency] = useState('high');
  // 새 할 일 날짜
  const [newTaskDate, setNewTaskDate] = useState('');
  
  // 가상의 할 일 목록 (실제로는 DB에서 가져올 예정)
  const dummyTasks = [
    { id: 1, title: '리액트 컴포넌트 작성하기', completed: false, date: new Date(), importance: 'high', urgency: 'high', quadrant: 1 },
    { id: 2, title: '일렉트론 앱 빌드하기', completed: false, date: new Date(), importance: 'high', urgency: 'low', quadrant: 2 },
    { id: 3, title: 'CSS 스타일 적용하기', completed: false, date: new Date(Date.now() - 86400000), importance: 'low', urgency: 'high', quadrant: 3 },
    { id: 4, title: '패키징 스크립트 작성하기', completed: false, date: new Date(Date.now() + 86400000), importance: 'low', urgency: 'low', quadrant: 4 },
  ];
  
  // 컴포넌트 마운트 시 할 일 목록 가져오기
  useEffect(() => {
    // 실제로는 데이터베이스에서 가져오는 비동기 작업
    setTasks(dummyTasks);
  }, []);

  // 날짜를 YYYY-MM-DD 형식으로 변환
  const formatDateForInput = (date) => {
    const d = new Date(date);
    let month = '' + (d.getMonth() + 1);
    let day = '' + d.getDate();
    const year = d.getFullYear();

    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;

    return [year, month, day].join('-');
  };

  // 일반 문자열로 날짜 표시
  const formatDate = (date) => {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return new Date(date).toLocaleDateString('ko-KR', options);
  };

  // 할 일 추가 모달 초기화
  const openAddModal = (quadrant) => {
    // 사분면에 따라 중요도와 긴급도 설정
    switch (quadrant) {
      case 1:
        setNewTaskImportance('high');
        setNewTaskUrgency('high');
        break;
      case 2:
        setNewTaskImportance('high');
        setNewTaskUrgency('low');
        break;
      case 3:
        setNewTaskImportance('low');
        setNewTaskUrgency('high');
        break;
      case 4:
        setNewTaskImportance('low');
        setNewTaskUrgency('low');
        break;
      default:
        setNewTaskImportance('high');
        setNewTaskUrgency('high');
    }
    
    setNewTaskText('');
    setNewTaskDate(formatDateForInput(new Date()));
    setIsAddModalOpen(true);
  };

  // 할 일 수정 모달 초기화
  const openEditModal = (task) => {
    setSelectedTask(task);
    setNewTaskText(task.title);
    setNewTaskDate(formatDateForInput(task.date));
    setNewTaskImportance(task.importance);
    setNewTaskUrgency(task.urgency);
    setIsEditModalOpen(true);
  };

  // 할 일 추가 함수
  const addTask = () => {
    if (newTaskText.trim() === '') return;
    
    const quadrant = getQuadrantFromImportanceUrgency(newTaskImportance, newTaskUrgency);
    
    const newTask = {
      id: Date.now(),
      title: newTaskText,
      completed: false,
      date: newTaskDate ? new Date(newTaskDate) : new Date(),
      importance: newTaskImportance,
      urgency: newTaskUrgency,
      quadrant: quadrant
    };
    
    setTasks([...tasks, newTask]);
    setIsAddModalOpen(false);
  };

  // 할 일 수정 함수
  const updateTask = () => {
    if (newTaskText.trim() === '') return;
    
    const quadrant = getQuadrantFromImportanceUrgency(newTaskImportance, newTaskUrgency);
    
    const updatedTask = {
      ...selectedTask,
      title: newTaskText,
      date: newTaskDate ? new Date(newTaskDate) : new Date(),
      importance: newTaskImportance,
      urgency: newTaskUrgency,
      quadrant: quadrant
    };
    
    setTasks(
      tasks.map(task => 
        task.id === selectedTask.id ? updatedTask : task
      )
    );
    
    setIsEditModalOpen(false);
  };

  // 할 일 삭제 함수
  const deleteTask = (taskId) => {
    setTasks(tasks.filter(task => task.id !== taskId));
  };

  // 중요도와 긴급도로부터 사분면 번호 계산
  const getQuadrantFromImportanceUrgency = (importance, urgency) => {
    if (importance === 'high' && urgency === 'high') return 1;
    if (importance === 'high' && urgency === 'low') return 2;
    if (importance === 'low' && urgency === 'high') return 3;
    if (importance === 'low' && urgency === 'low') return 4;
    return 1; // 기본값
  };

  // 드래그 시작 핸들러
  const handleDragStart = (e, task) => {
    setDraggedTask(task);
    e.dataTransfer.setData('text/plain', task.id);
    // 드래그 요소의 이미지 설정
    const dragImage = document.createElement('div');
    dragImage.textContent = task.title;
    dragImage.style.padding = '8px';
    dragImage.style.backgroundColor = 'var(--primary-color)';
    dragImage.style.color = 'white';
    dragImage.style.borderRadius = '4px';
    dragImage.style.position = 'absolute';
    dragImage.style.top = '-1000px';
    document.body.appendChild(dragImage);
    e.dataTransfer.setDragImage(dragImage, 0, 0);
    setTimeout(() => {
      document.body.removeChild(dragImage);
    }, 0);
  };

  // 드래그 오버 핸들러
  const handleDragOver = (e) => {
    e.preventDefault();
  };

  // 드롭 핸들러
  const handleDrop = (e, quadrant) => {
    e.preventDefault();
    
    if (draggedTask) {
      // 중요도와 긴급도 설정
      let importance, urgency;
      
      switch (quadrant) {
        case 1:
          importance = 'high';
          urgency = 'high';
          break;
        case 2:
          importance = 'high';
          urgency = 'low';
          break;
        case 3:
          importance = 'low';
          urgency = 'high';
          break;
        case 4:
          importance = 'low';
          urgency = 'low';
          break;
        default:
          importance = 'high';
          urgency = 'high';
      }
      
      // 드래그된 할 일 업데이트
      const updatedTasks = tasks.map(task => {
        if (task.id === draggedTask.id) {
          return {
            ...task,
            quadrant: quadrant,
            importance: importance,
            urgency: urgency
          };
        }
        return task;
      });
      
      setTasks(updatedTasks);
      setDraggedTask(null);
    }
  };

  // 각 사분면의 할 일 목록 필터링
  const getTasksForQuadrant = (quadrant) => {
    return tasks.filter(task => task.quadrant === quadrant);
  };

  // 각 사분면의 제목과 설명
  const getQuadrantInfo = (quadrant) => {
    switch (quadrant) {
      case 1:
        return {
          title: '중요 & 긴급',
          description: '즉시 처리',
          color: '#e74c3c'
        };
      case 2:
        return {
          title: '중요 & 긴급하지 않음',
          description: '계획 수립',
          color: '#3498db'
        };
      case 3:
        return {
          title: '중요하지 않음 & 긴급',
          description: '위임하기',
          color: '#f39c12'
        };
      case 4:
        return {
          title: '중요하지 않음 & 긴급하지 않음',
          description: '최소화하기',
          color: '#27ae60'
        };
      default:
        return {
          title: '',
          description: '',
          color: '#95a5a6'
        };
    }
  };

  // 각 사분면 렌더링 함수
  const renderQuadrant = (quadrant) => {
    const quadrantInfo = getQuadrantInfo(quadrant);
    const quadrantTasks = getTasksForQuadrant(quadrant);
    
    return (
      <div 
        className="matrix-quadrant" 
        onDragOver={handleDragOver}
        onDrop={(e) => handleDrop(e, quadrant)}
        style={{ borderColor: quadrantInfo.color }}
      >
        <div className="quadrant-header" style={{ backgroundColor: quadrantInfo.color }}>
          <h3>{quadrantInfo.title}</h3>
          <p>{quadrantInfo.description}</p>
        </div>
        
        <div className="quadrant-tasks">
          {quadrantTasks.length === 0 ? (
            <div className="empty-quadrant">
              <p>할 일이 없습니다</p>
            </div>
          ) : (
            quadrantTasks.map(task => (
              <div 
                key={task.id} 
                className={`matrix-task ${task.completed ? 'completed' : ''}`}
                draggable
                onDragStart={(e) => handleDragStart(e, task)}
              >
                <div className="matrix-task-content" onClick={() => openEditModal(task)}>
                  {task.title}
                  <span className="matrix-task-date">{formatDate(task.date)}</span>
                </div>
                <button className="secondary" onClick={() => deleteTask(task.id)}>
                  <i className="material-icons">close</i>
                </button>
              </div>
            ))
          )}
          
          <button className="add-task-button" onClick={() => openAddModal(quadrant)}>
            <i className="material-icons">add</i> 할 일 추가
          </button>
        </div>
      </div>
    );
  };

  return (
    <div className="matrix-container">
      <div className="matrix-header">
        <h1>아이젠하워 매트릭스</h1>
        <p>중요도와 긴급도에 따라 할 일을 분류하세요. 항목을 다른 사분면으로 드래그할 수 있습니다.</p>
      </div>
      
      <div className="matrix-grid">
        {renderQuadrant(1)}
        {renderQuadrant(2)}
        {renderQuadrant(3)}
        {renderQuadrant(4)}
      </div>
      
      {/* 할 일 추가 모달 */}
      {isAddModalOpen && (
        <div className="modal">
          <div className="modal-content">
            <h2>새 할 일 추가</h2>
            
            <div className="form-group">
              <label>제목</label>
              <input
                type="text"
                placeholder="할 일 내용"
                value={newTaskText}
                onChange={(e) => setNewTaskText(e.target.value)}
                autoFocus
              />
            </div>
            
            <div className="form-group">
              <label>날짜</label>
              <input
                type="date"
                value={newTaskDate}
                onChange={(e) => setNewTaskDate(e.target.value)}
              />
            </div>
            
            <div className="form-group">
              <label>중요도</label>
              <select 
                value={newTaskImportance} 
                onChange={(e) => setNewTaskImportance(e.target.value)}
              >
                <option value="high">높음</option>
                <option value="low">낮음</option>
              </select>
            </div>
            
            <div className="form-group">
              <label>긴급도</label>
              <select 
                value={newTaskUrgency} 
                onChange={(e) => setNewTaskUrgency(e.target.value)}
              >
                <option value="high">높음</option>
                <option value="low">낮음</option>
              </select>
            </div>
            
            <div className="modal-actions">
              <button onClick={addTask}>추가</button>
              <button className="secondary" onClick={() => setIsAddModalOpen(false)}>취소</button>
            </div>
          </div>
        </div>
      )}
      
      {/* 할 일 수정 모달 */}
      {isEditModalOpen && selectedTask && (
        <div className="modal">
          <div className="modal-content">
            <h2>할 일 수정</h2>
            
            <div className="form-group">
              <label>제목</label>
              <input
                type="text"
                placeholder="할 일 내용"
                value={newTaskText}
                onChange={(e) => setNewTaskText(e.target.value)}
                autoFocus
              />
            </div>
            
            <div className="form-group">
              <label>날짜</label>
              <input
                type="date"
                value={newTaskDate}
                onChange={(e) => setNewTaskDate(e.target.value)}
              />
            </div>
            
            <div className="form-group">
              <label>중요도</label>
              <select 
                value={newTaskImportance} 
                onChange={(e) => setNewTaskImportance(e.target.value)}
              >
                <option value="high">높음</option>
                <option value="low">낮음</option>
              </select>
            </div>
            
            <div className="form-group">
              <label>긴급도</label>
              <select 
                value={newTaskUrgency} 
                onChange={(e) => setNewTaskUrgency(e.target.value)}
              >
                <option value="high">높음</option>
                <option value="low">낮음</option>
              </select>
            </div>
            
            <div className="form-group checkbox-group">
              <label>
                <input
                  type="checkbox"
                  checked={selectedTask.completed}
                  onChange={(e) => {
                    setSelectedTask({...selectedTask, completed: e.target.checked});
                  }}
                />
                완료됨
              </label>
            </div>
            
            <div className="modal-actions">
              <button onClick={updateTask}>저장</button>
              <button className="secondary" onClick={() => setIsEditModalOpen(false)}>취소</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default MatrixView; 