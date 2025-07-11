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

  const updateUser = async (
    id: string,
    userData: Partial<IUser>,
  ): Promise<IUser> => {
    return await $fetch(`/api/users/${id}`, {
      method: "POST",
      body: { ...userData, _method: "PATCH" },
    });
  };

  const deleteUser = async (id: string): Promise<void> => {
    return await $fetch(`/api/users/${id}`, {
      method: "POST",
      body: { _method: "DELETE" },
    });
  };

  return {
    getUsers,
    createUser,
    updateUser,
    deleteUser,
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

  const updateProject = async (
    id: string,
    projectData: Partial<IProject>,
  ): Promise<IProject> => {
    return await $fetch(`/api/projects/${id}`, {
      method: "POST",
      body: { ...projectData, _method: "PATCH" },
    });
  };

  const deleteProject = async (id: string): Promise<void> => {
    return await $fetch(`/api/projects/${id}`, {
      method: "POST",
      body: { _method: "DELETE" },
    });
  };

  return {
    getProjects,
    createProject,
    updateProject,
    deleteProject,
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

  const updateTestCase = async (
    id: string,
    testCaseData: Partial<ITestCase>,
  ): Promise<ITestCase> => {
    return await $fetch(`/api/test-cases/${id}`, {
      method: "POST",
      body: { ...testCaseData, _method: "PATCH" },
    });
  };

  const deleteTestCase = async (id: string): Promise<void> => {
    return await $fetch(`/api/test-cases/${id}`, {
      method: "POST",
      body: { _method: "DELETE" },
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
    updateTestCase,
    deleteTestCase,
    validateTestCase,
  };
};
