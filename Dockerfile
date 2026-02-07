# Step 1: Build the Next.js app
# FROM node:iron-slim AS builder
# WORKDIR /app

# COPY package*.json ./
# RUN npm install 

# COPY . .
# RUN npm run build

# # Step 2: Production container
# FROM node:iron-slim
# WORKDIR /app

# COPY --from=builder /app ./

# EXPOSE 3000
# CMD ["npm", "start"]




# -------------------------------
# Stage 1: Install dependencies
# -------------------------------
FROM node:iron-slim AS deps
WORKDIR /app

# Copy package.json and lock file only (better cache)
COPY package.json package-lock.json* ./

# Install dependencies (only production ones later)
RUN npm ci

# -------------------------------
# Stage 2: Build the Next.js app
# -------------------------------
FROM node:iron-slim AS builder
WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build the Next.js app
RUN npm run build

# -------------------------------
# Stage 3: Production runtime
# -------------------------------
FROM node:iron-slim AS runner
WORKDIR /app

# Set NODE_ENV to production
ENV NODE_ENV=production

# Copy only necessary files
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Expose port
EXPOSE 3000

# Start Next.js in production
CMD ["npm", "start"]

