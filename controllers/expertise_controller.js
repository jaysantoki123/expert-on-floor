import Expertise from '../models/Expertise.js';

// GET /expertise - List all active expertise categories (Public)
export const getExpertise = async (req, res) => {
  try {
    const expertiseList = await Expertise.find({ isActive: true });
    res.json(expertiseList);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Admin Endpoints (Already in admin_controller.js, will extend)
export const createExpertise = async (req, res) => {
  try {
    const { name, description, icon } = req.body;
    const newExpertise = new Expertise({ name, description, icon });
    await newExpertise.save();
    res.status(201).json(newExpertise);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const updateExpertise = async (req, res) => {
  try {
    const updatedExpertise = await Expertise.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true }
    );
    if (!updatedExpertise) return res.status(404).json({ message: 'Expertise not found' });
    res.json(updatedExpertise);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const deleteExpertise = async (req, res) => {
  try {
    const deletedExpertise = await Expertise.findByIdAndDelete(req.params.id);
    if (!deletedExpertise) return res.status(404).json({ message: 'Expertise not found' });
    res.json({ message: 'Expertise deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
