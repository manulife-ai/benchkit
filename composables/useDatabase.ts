import type { IProject, ITestCase, IUser } from "~/models";

export const useUsers = () => {
  const getUsers = async (): Promise<IUser[]> => {
    return await $fetch("/api/users");
  };

  const createUser = async (userData: Partial<IUser>): Promise<IUser> => {
    return await $fetch("/api/users", {
      method: "POST",
      body: userData,
    });
  };

  return {
    getUsers,
    createUser,
  };
};

export const useProjects = () => {
  const getProjects = async (): Promise<IProject[]> => {
    return await $fetch("/api/projects");
  };

  const createProject = async (
    projectData: Partial<IProject>,
  ): Promise<IProject> => {
    return await $fetch("/api/projects", {
      method: "POST",
      body: projectData,
    });
  };

  return {
    getProjects,
    createProject,
  };
};

export const useTestCases = () => {
  const getTestCases = async (query?: {
    project?: string;
    user?: string;
  }): Promise<ITestCase[]> => {
    return await $fetch("/api/test-cases", {
      query,
    });
  };

  const createTestCase = async (
    testCaseData: Partial<ITestCase>,
  ): Promise<ITestCase> => {
    return await $fetch("/api/test-cases", {
      method: "POST",
      body: testCaseData,
    });
  };

  const validateTestCase = async (
    id: string,
    validationData: {
      user: string;
      comment?: string;
      data: Record<string, any>;
    },
  ): Promise<ITestCase> => {
    return await $fetch(`/api/test-cases/${id}/validate`, {
      method: "POST",
      body: validationData,
    });
  };

  return {
    getTestCases,
    createTestCase,
    validateTestCase,
  };
};
