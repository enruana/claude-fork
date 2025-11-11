---
allowed-tools: Task, Write
description: Export context from current fork with AI-generated summary using specialized agent
argument-hint: [export-name]
---

📤 **Professional Export with Specialized Agent**

I'll use our specialized **Export Specialist Agent** to analyze this conversation and create a comprehensive export summary. The agent will extract all valuable knowledge, technical decisions, and insights for seamless continuation in other contexts.

**Export Process:**
1. 🔍 **Deep Conversation Analysis** - Extract key insights, decisions, and technical solutions
2. 📋 **Structured Knowledge Capture** - Organize information into actionable sections
3. 💾 **Save to Export Repository** - Store at `.claude/.claude-fork/exports/$ARGUMENTS.md`

Please use the export-specialist subagent to analyze our current Claude Fork conversation and create a comprehensive export summary. After the analysis, I will save the export content to .claude/.claude-fork/exports/$ARGUMENTS.md

**Export Requirements:**
- Export Name: $ARGUMENTS
- Target Location: .claude/.claude-fork/exports/$ARGUMENTS.md
- Working Directory: Current project directory
- Return Format: Structured markdown content ready for file export

**Analysis Framework:**

## 📋 Executive Summary
Brief overview of session objectives, accomplishments, key decisions made and their impact, overall outcomes and success metrics.

## 🔍 Technical Analysis  
Code changes with specific file paths and line numbers, architecture decisions and technical trade-offs, dependencies and configurations, commands executed and their purposes.

## 💡 Key Insights & Learnings
Important discoveries and breakthrough moments, problem-solving approaches and mental models, best practices identified, pitfalls encountered and solutions implemented.

## 🛠️ Implementation Details
Step-by-step processes followed, tool usage patterns and optimization techniques, configuration changes and setup procedures, testing approaches and validation methods.

## 🚀 Continuation Roadmap
Immediate next steps with priority ranking, pending tasks and identified follow-ups, long-term objectives and milestone planning, resource requirements and dependencies.

## 📚 Knowledge Assets
Reusable patterns and templates discovered, reference materials and learning resources, methodology insights and workflow improvements, documentation that should be preserved.

**Success Criteria:**
- Include specific file paths, line numbers, and technical references
- Focus on actionable information for seamless continuation
- Enable someone else to pick up exactly where we left off
- Use professional markdown formatting with clear sections

After receiving the export content from the subagent, I will:
1. Create the exports directory if it doesn't exist
2. Write the content to .claude/.claude-fork/exports/$ARGUMENTS.md
3. Confirm successful export creation