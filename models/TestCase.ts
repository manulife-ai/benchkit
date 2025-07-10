import { model, Schema, Types } from "mongoose";

export interface ITestCaseInput {
  type: "pdf" | "img" | "txt" | "json";
  file: string; // file path in blob storage
  filename: string;
}

export interface ITestCaseAssigned {
  user?: Types.ObjectId;
  project: Types.ObjectId;
}

export interface ITestCaseValidated {
  timestamp: Date;
  user: Types.ObjectId;
  comment?: string;
  data: Record<string, any>; // validated JSON data
}

export interface ITestCase {
  _id?: string;
  inputs: ITestCaseInput[];
  original: Record<string, any>; // original expected output JSON
  assigned: ITestCaseAssigned[];
  validated: ITestCaseValidated[];
  createdAt?: Date;
  updatedAt?: Date;
}

const testCaseInputSchema = new Schema<ITestCaseInput>(
  {
    type: {
      type: String,
      enum: ["pdf", "img", "txt", "json"],
      required: true,
    },
    file: {
      type: String,
      required: true,
    },
    filename: {
      type: String,
      required: true,
    },
  },
  { _id: false },
);

const testCaseAssignedSchema = new Schema<ITestCaseAssigned>(
  {
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: false,
    },
    project: {
      type: Schema.Types.ObjectId,
      ref: "Project",
      required: true,
    },
  },
  { _id: false },
);

const testCaseValidatedSchema = new Schema<ITestCaseValidated>(
  {
    timestamp: {
      type: Date,
      default: Date.now,
    },
    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    comment: {
      type: String,
      trim: true,
    },
    data: {
      type: Schema.Types.Mixed,
      required: true,
    },
  },
  { _id: false },
);

const testCaseSchema = new Schema<ITestCase>(
  {
    inputs: [testCaseInputSchema],
    original: {
      type: Schema.Types.Mixed,
      required: true,
    },
    assigned: [testCaseAssignedSchema],
    validated: [testCaseValidatedSchema],
  },
  {
    timestamps: true,
  },
);

export default model<ITestCase>("TestCase", testCaseSchema);
