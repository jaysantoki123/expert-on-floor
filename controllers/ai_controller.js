import { GoogleGenerativeAI } from '@google/generative-ai';
import Expert from '../models/Expert.js';
import User from '../models/User.js';

// Initializing Google Generative AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

// POST /ai/smart-match - Find the best expert based on user problem description
export const smartMatch = async (req, res) => {
  try {
    const { problemDescription } = req.body;
    if (!problemDescription) return res.status(400).json({ message: "Problem description is required" });

    // Fetch all verified experts with their basic info
    const experts = await Expert.find({ verificationStatus: 'verified' })
      .populate('userId', 'fullName profileImage')
      .select('expertise bio yearsOfExperience avgRating');

    if (experts.length === 0) return res.json({ message: "No experts available for matching", recommendations: [] });

    // Prepare expert data for AI
    const expertListStr = experts.map((e, idx) => 
      `Expert ID: ${e._id}, Name: ${e.userId.fullName}, Expertise: ${e.expertise.join(', ')}, Bio: ${e.bio}, Experience: ${e.yearsOfExperience} years, Rating: ${e.avgRating}`
    ).join('\n');

    const prompt = `
      You are an AI assistant for "Expert on Floor", a platform connecting industrial businesses with experts.
      A client has the following industrial problem: "${problemDescription}".
      
      Here is a list of available experts:
      ${expertListStr}
      
      Please analyze the problem and recommend the top 3 most suitable experts from the list above. 
      For each recommendation, provide:
      1. Expert ID
      2. Reasoning for why they are a good match.
      3. A potential first step they might take to solve the problem.
      
      Format your response as a JSON array of objects with keys: expertId, reasoning, and firstStep.
      Return ONLY the JSON array.
    `;

    const result = await model.generateContent(prompt);
    const responseText = result.response.text();
    
    // Clean potential markdown code blocks if AI returns them
    const cleanedJson = responseText.replace(/```json|```/g, '').trim();
    const recommendations = JSON.parse(cleanedJson);

    // Merge recommendations with full expert data
    const fullRecommendations = recommendations.map(rec => {
      const expertData = experts.find(e => e._id.toString() === rec.expertId);
      return { ...rec, expertData };
    });

    res.json({ recommendations: fullRecommendations });
  } catch (error) {
    console.error("Smart Match AI Error:", error);
    res.status(500).json({ message: "AI matching failed", error: error.message });
  }
};

// POST /ai/profile-optimizer - Suggest improvements for an expert's profile
export const optimizeProfile = async (req, res) => {
  try {
    const expert = await Expert.findOne({ userId: req.user._id });
    if (!expert) return res.status(404).json({ message: "Expert profile not found" });

    const prompt = `
      Analyze the following expert profile bio and expertise:
      Bio: "${expert.bio}"
      Expertise: "${expert.expertise.join(', ')}"
      
      Suggest 3 specific improvements to make this profile more appealing to industrial clients seeking high-end consultation.
      Focus on highlighting technical results, years of specialized experience, and specific industrial problem-solving capabilities.
      
      Format your response as a JSON object with keys: suggestions (array of strings) and improvedBio (string).
      Return ONLY the JSON object.
    `;

    const result = await model.generateContent(prompt);
    const responseText = result.response.text();
    
    const cleanedJson = responseText.replace(/```json|```/g, '').trim();
    const optimization = JSON.parse(cleanedJson);

    res.json(optimization);
  } catch (error) {
    console.error("Profile Optimizer AI Error:", error);
    res.status(500).json({ message: "AI optimization failed", error: error.message });
  }
};

// POST /ai/analyze-challenge - Quick AI analysis of an industrial challenge
export const analyzeChallenge = async (req, res) => {
  try {
    const { challenge } = req.body;
    if (!challenge) return res.status(400).json({ message: "Challenge description is required" });

    const prompt = `
      An industrial client is facing the following challenge: "${challenge}".
      Provide a brief, professional technical analysis including:
      1. Possible root causes.
      2. Required specialized expertise categories (e.g., EV, Foundry, Machining).
      3. Critical safety or compliance considerations.
      
      Format your response as a professional brief in bullet points.
    `;

    const result = await model.generateContent(prompt);
    res.json({ analysis: result.response.text() });
  } catch (error) {
    res.status(500).json({ message: "AI analysis failed", error: error.message });
  }
};
