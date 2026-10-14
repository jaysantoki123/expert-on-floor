import axios from 'axios';

const BASE_URL = 'http://localhost:5000/v1';

async function testFlow() {
  try {
    console.log('--- Starting Flow Test ---');

    // 1. Register
    const regRes = await axios.post(`${BASE_URL}/auth/register`, {
      name: 'Test Learner',
      email: `learner_${Date.now()}@test.com`,
      password: 'password123',
      role: 'learner'
    });
    console.log('✅ Learner Registered');
    const token = regRes.data.data.token;

    // 2. Login
    const loginRes = await axios.post(`${BASE_URL}/auth/login`, {
      email: regRes.data.data.user.email,
      password: 'password123'
    });
    console.log('✅ Learner Logged In');

    // 3. Register as Expert
    const expRegRes = await axios.post(`${BASE_URL}/experts/register`, {
      title: 'Senior Software Engineer',
      category: 'Technology',
      experienceYears: 10,
      pricePerHour: 1000,
      skills: ['Node.js', 'React', 'MySQL'],
      bio: 'Expert in backend development'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Expert Profile Created');

    // 4. Get Experts
    const listRes = await axios.get(`${BASE_URL}/experts`);
    console.log(`✅ Experts Found: ${listRes.data.data.length}`);

    // 5. Generate Roadmap
    const roadmapRes = await axios.post(`${BASE_URL}/roadmap/generate`, {
      goal: 'Become a Cloud Architect',
      currentLevel: 'intermediate',
      timeAvailableWeekly: 10
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ AI Roadmap Generated:', roadmapRes.data.data.title);

    console.log('--- Flow Test Completed Successfully ---');
  } catch (error) {
    console.error('❌ Test Failed:', error.response?.data || error.message);
  }
}

testFlow();
