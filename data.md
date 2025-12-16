import React, { useState, useEffect } from 'react';

const scheduleData = [
  {
    time: "11:00 AM",
    endTime: "11:30 AM",
    startMinutes: 11 * 60,
    endMinutes: 11 * 60 + 30,
    duration: "30 min",
    title: "Wake Up & Morning Routine",
    description: "Get ready, breakfast",
    category: "personal",
    icon: "☀️"
  },
  {
    time: "11:30 AM",
    endTime: "1:30 PM",
    startMinutes: 11 * 60 + 30,
    endMinutes: 13 * 60 + 30,
    duration: "2 hours",
    title: "Family Time",
    description: "Family lunch together, spend time with parents/family",
    category: "family",
    icon: "👨‍👩‍👦"
  },
  {
    time: "1:30 PM",
    endTime: "2:30 PM",
    startMinutes: 13 * 60 + 30,
    endMinutes: 14 * 60 + 30,
    duration: "1 hour",
    title: "Personal Break",
    description: "Relax, prepare for the day",
    category: "personal",
    icon: "🧘"
  },
  {
    time: "2:30 PM",
    endTime: "5:00 PM",
    startMinutes: 14 * 60 + 30,
    endMinutes: 17 * 60,
    duration: "2.5 hours",
    title: "Wife Time + Office Standby",
    description: "Quality time with wife before she leaves at 5pm. Available if office calls come in.",
    category: "wife",
    icon: "💑"
  },
  {
    time: "5:00 PM",
    endTime: "6:00 PM",
    startMinutes: 17 * 60,
    endMinutes: 18 * 60,
    duration: "1 hour",
    title: "Personal + Family Time",
    description: "Personal activities and family interaction",
    category: "family",
    icon: "🏠"
  },
  {
    time: "6:00 PM",
    endTime: "9:00 PM",
    startMinutes: 18 * 60,
    endMinutes: 21 * 60,
    duration: "3 hours",
    title: "Office Work + Standby",
    description: "Development work, PRs, code reviews. Handle any ad-hoc requests.",
    category: "work",
    icon: "💻"
  },
  {
    time: "9:00 PM",
    endTime: "10:30 PM",
    startMinutes: 21 * 60,
    endMinutes: 22 * 60 + 30,
    duration: "1.5 hours",
    title: "Office Calls",
    description: "Mandatory call block - fully focused on office",
    category: "work",
    icon: "📞"
  },
  {
    time: "10:30 PM",
    endTime: "11:30 PM",
    startMinutes: 22 * 60 + 30,
    endMinutes: 23 * 60 + 30,
    duration: "1 hour",
    title: "Dinner & Break",
    description: "Eat, decompress",
    category: "personal",
    icon: "🍽️"
  },
  {
    time: "11:30 PM",
    endTime: "12:30 AM",
    startMinutes: 23 * 60 + 30,
    endMinutes: 24 * 60 + 30,
    duration: "1 hour",
    title: "Wife + Family Time",
    description: "Quality evening time with loved ones",
    category: "wife",
    icon: "❤️"
  },
  {
    time: "12:30 AM",
    endTime: "3:30 AM",
    startMinutes: 0 * 60 + 30,
    endMinutes: 3 * 60 + 30,
    duration: "3 hours",
    title: "Freelance Preparation",
    description: "Peak deep work - Master frontend engineering, Advanced React/Next.js, system design, portfolio projects",
    category: "freelance",
    icon: "🚀",
    isNextDay: true
  },
  {
    time: "3:30 AM",
    endTime: "4:30 AM",
    startMinutes: 3 * 60 + 30,
    endMinutes: 4 * 60 + 30,
    duration: "1 hour",
    title: "Connect with Wife",
    description: "She returns around 4am - wind down together",
    category: "wife",
    icon: "🌙",
    isNextDay: true
  },
  {
    time: "4:30 AM",
    endTime: "11:00 AM",
    startMinutes: 4 * 60 + 30,
    endMinutes: 11 * 60,
    duration: "6.5 hours",
    title: "Sleep",
    description: "Rest and recovery",
    category: "sleep",
    icon: "😴",
    isNextDay: true
  }
];

const categoryColors = {
  personal: { bg: "bg-purple-100", border: "border-purple-400", text: "text-purple-700", dot: "bg-purple-500", glow: "shadow-purple-500/50" },
  family: { bg: "bg-green-100", border: "border-green-400", text: "text-green-700", dot: "bg-green-500", glow: "shadow-green-500/50" },
  wife: { bg: "bg-pink-100", border: "border-pink-400", text: "text-pink-700", dot: "bg-pink-500", glow: "shadow-pink-500/50" },
  work: { bg: "bg-blue-100", border: "border-blue-400", text: "text-blue-700", dot: "bg-blue-500", glow: "shadow-blue-500/50" },
  freelance: { bg: "bg-orange-100", border: "border-orange-400", text: "text-orange-700", dot: "bg-orange-500", glow: "shadow-orange-500/50" },
  sleep: { bg: "bg-indigo-100", border: "border-indigo-400", text: "text-indigo-700", dot: "bg-indigo-500", glow: "shadow-indigo-500/50" }
};

const categoryLabels = {
  personal: "Personal",
  family: "Family",
  wife: "Wife Time",
  work: "Office",
  freelance: "Freelance Prep",
  sleep: "Sleep"
};

function getCurrentActivity(now) {
  const hours = now.getHours();
  const minutes = now.getMinutes();
  const currentMinutes = hours * 60 + minutes;
  
  for (const item of scheduleData) {
    if (item.isNextDay) {
      // For activities after midnight (12:30 AM - 11:00 AM)
      if (currentMinutes >= item.startMinutes && currentMinutes < item.endMinutes) {
        return item;
      }
    } else {
      // For activities before midnight
      if (item.endMinutes > 24 * 60) {
        // Activity spans midnight (11:30 PM - 12:30 AM)
        if (currentMinutes >= item.startMinutes || currentMinutes < (item.endMinutes - 24 * 60)) {
          return item;
        }
      } else {
        if (currentMinutes >= item.startMinutes && currentMinutes < item.endMinutes) {
          return item;
        }
      }
    }
  }
  
  return scheduleData[0]; // Default fallback
}

function getTimeRemaining(now, activity) {
  const hours = now.getHours();
  const minutes = now.getMinutes();
  const currentMinutes = hours * 60 + minutes;
  
  let endMinutes = activity.endMinutes;
  
  // Handle midnight crossing
  if (activity.endMinutes > 24 * 60) {
    endMinutes = activity.endMinutes - 24 * 60;
    if (currentMinutes > 12 * 60) {
      // Before midnight
      return (24 * 60 - currentMinutes) + endMinutes;
    }
  }
  
  if (activity.isNextDay && currentMinutes > activity.endMinutes) {
    return 0;
  }
  
  return Math.max(0, endMinutes - currentMinutes);
}

function formatTime(date) {
  return date.toLocaleTimeString('en-US', { 
    hour: 'numeric', 
    minute: '2-digit',
    hour12: true 
  });
}

export default function DailyTimetable() {
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [expandedItem, setExpandedItem] = useState(null);
  const [currentTime, setCurrentTime] = useState(new Date());
  const [currentActivity, setCurrentActivity] = useState(null);

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setCurrentTime(now);
      setCurrentActivity(getCurrentActivity(now));
    };
    
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  const filteredSchedule = selectedCategory 
    ? scheduleData.filter(item => item.category === selectedCategory)
    : scheduleData;

  const totalHours = {
    personal: 2.5,
    family: 3,
    wife: 4.5,
    work: 4.5,
    freelance: 3,
    sleep: 6.5
  };

  const timeRemaining = currentActivity ? getTimeRemaining(currentTime, currentActivity) : 0;
  const remainingHours = Math.floor(timeRemaining / 60);
  const remainingMinutes = timeRemaining % 60;

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 p-4 md:p-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="text-center mb-6">
          <h1 className="text-3xl md:text-4xl font-bold text-white mb-2">
            Daily Schedule
          </h1>
          <p className="text-slate-400">Abhishek's Balanced Routine</p>
        </div>

        {/* Current Activity Banner */}
        {currentActivity && (
          <div className={`mb-6 p-5 rounded-2xl ${categoryColors[currentActivity.category].bg} 
            ${categoryColors[currentActivity.category].border} border-2 
            shadow-lg ${categoryColors[currentActivity.category].glow}`}
          >
            <div className="flex items-center justify-between flex-wrap gap-3">
              <div className="flex items-center gap-3">
                <div className="relative">
                  <span className="text-4xl">{currentActivity.icon}</span>
                  <span className="absolute -top-1 -right-1 flex h-3 w-3">
                    <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                    <span className="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
                  </span>
                </div>
                <div>
                  <p className="text-xs font-medium text-slate-500 uppercase tracking-wider">
                    🔴 Live Now • {formatTime(currentTime)}
                  </p>
                  <h2 className={`text-xl md:text-2xl font-bold ${categoryColors[currentActivity.category].text}`}>
                    {currentActivity.title}
                  </h2>
                  <p className={`text-sm ${categoryColors[currentActivity.category].text} opacity-75 mt-1`}>
                    {currentActivity.description}
                  </p>
                </div>
              </div>
              <div className="text-right">
                <div className={`text-xs ${categoryColors[currentActivity.category].text} opacity-70`}>
                  Time Remaining
                </div>
                <div className={`text-2xl md:text-3xl font-bold ${categoryColors[currentActivity.category].text}`}>
                  {remainingHours > 0 && `${remainingHours}h `}{remainingMinutes}m
                </div>
                <div className={`text-xs ${categoryColors[currentActivity.category].text} opacity-70`}>
                  {currentActivity.time} - {currentActivity.endTime}
                </div>
              </div>
            </div>
            
            {/* Progress Bar */}
            <div className="mt-4">
              <div className="h-2 bg-white/30 rounded-full overflow-hidden">
                <div 
                  className={`h-full ${categoryColors[currentActivity.category].dot} transition-all duration-1000`}
                  style={{ 
                    width: `${Math.max(5, 100 - (timeRemaining / (parseInt(currentActivity.duration) * 60 || 60)) * 100)}%` 
                  }}
                />
              </div>
            </div>
          </div>
        )}

        {/* Stats Summary */}
        <div className="grid grid-cols-3 md:grid-cols-6 gap-2 mb-6">
          {Object.entries(totalHours).map(([cat, hours]) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(selectedCategory === cat ? null : cat)}
              className={`p-3 rounded-xl transition-all duration-300 ${
                selectedCategory === cat 
                  ? 'ring-2 ring-white scale-105' 
                  : 'hover:scale-102'
              } ${categoryColors[cat].bg} ${currentActivity?.category === cat ? 'ring-2 ring-offset-2 ring-offset-slate-900 ring-red-400' : ''}`}
            >
              <div className={`text-xs font-medium ${categoryColors[cat].text} opacity-80`}>
                {categoryLabels[cat]}
              </div>
              <div className={`text-lg font-bold ${categoryColors[cat].text}`}>
                {hours}h
              </div>
            </button>
          ))}
        </div>

        {selectedCategory && (
          <div className="text-center mb-4">
            <button 
              onClick={() => setSelectedCategory(null)}
              className="text-sm text-slate-400 hover:text-white transition-colors"
            >
              ✕ Clear filter
            </button>
          </div>
        )}

        {/* Timeline */}
        <div className="relative">
          {/* Vertical line */}
          <div className="absolute left-6 md:left-8 top-0 bottom-0 w-0.5 bg-slate-700" />

          <div className="space-y-4">
            {filteredSchedule.map((item, index) => {
              const colors = categoryColors[item.category];
              const isExpanded = expandedItem === index;
              const isCurrentActivity = currentActivity?.title === item.title;
              
              return (
                <div 
                  key={index}
                  className="relative pl-14 md:pl-20"
                  onClick={() => setExpandedItem(isExpanded ? null : index)}
                >
                  {/* Timeline dot */}
                  <div className={`absolute left-4 md:left-6 w-4 h-4 rounded-full ${colors.dot} 
                    ring-4 ring-slate-800 z-10 transition-transform duration-300
                    ${isExpanded ? 'scale-125' : ''} ${isCurrentActivity ? 'animate-pulse ring-red-400' : ''}`} 
                  />

                  {/* Card */}
                  <div className={`${colors.bg} ${colors.border} border-l-4 rounded-lg p-4 
                    cursor-pointer transition-all duration-300 hover:shadow-lg
                    ${isExpanded ? 'shadow-xl' : ''} 
                    ${isCurrentActivity ? 'ring-2 ring-red-400 shadow-lg' : ''}`}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-xl">{item.icon}</span>
                          <h3 className={`font-semibold ${colors.text}`}>
                            {item.title}
                          </h3>
                          {isCurrentActivity && (
                            <span className="px-2 py-0.5 bg-red-500 text-white text-xs rounded-full animate-pulse">
                              NOW
                            </span>
                          )}
                        </div>
                        <div className="flex items-center gap-3 text-sm text-slate-600 mb-2">
                          <span className="font-medium">{item.time} - {item.endTime}</span>
                          <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${colors.bg} ${colors.text} border ${colors.border}`}>
                            {item.duration}
                          </span>
                        </div>
                        <p className={`text-sm ${colors.text} opacity-80 ${isExpanded ? '' : 'line-clamp-1'}`}>
                          {item.description}
                        </p>
                      </div>
                      <div className={`text-slate-400 transition-transform duration-300 ${isExpanded ? 'rotate-180' : ''}`}>
                        ▼
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Footer Summary */}
        <div className="mt-8 p-4 bg-slate-800/50 rounded-xl border border-slate-700">
          <h3 className="text-white font-semibold mb-3 text-center">Daily Breakdown</h3>
          <div className="flex flex-wrap justify-center gap-4">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-blue-500" />
              <span className="text-slate-300 text-sm">Office: 4.5h</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-pink-500" />
              <span className="text-slate-300 text-sm">Wife: 4.5h</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-green-500" />
              <span className="text-slate-300 text-sm">Family: 3h</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-orange-500" />
              <span className="text-slate-300 text-sm">Freelance: 3h</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-indigo-500" />
              <span className="text-slate-300 text-sm">Sleep: 6.5h</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}