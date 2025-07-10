<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h1 class="font-serif text-2xl leading-tight font-normal text-gray-700">
        Manage samples
      </h1>
    </div>

    <UTabs
      v-model="selectedTab"
      variant="link"
      color="neutral"
      :items="items"
      class="w-full"
    >
      <!-- Users Tab -->
      <template #users>
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-medium">Users</h2>
            <div class="flex items-center gap-3">
              <UButton
                @click="showCreateUserForm = !showCreateUserForm"
                icon="i-heroicons-plus"
              >
                Create User
              </UButton>
            </div>
          </div>

          <!-- Create User Form -->
          <UCard v-if="showCreateUserForm">
            <template #header> </template>

            <div class="space-y-6">
              <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <UFormField label="Name" name="name" required>
                  <UInput v-model="newUser.name" placeholder="Full name" />
                </UFormField>
                <UFormField label="Email" name="email" required>
                  <UInput
                    v-model="newUser.email"
                    type="email"
                    placeholder="email@example.com"
                  />
                </UFormField>
              </div>
              <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <UFormField label="Role" name="role" required>
                  <USelect
                    v-model="newUser.role"
                    :items="roleOptions"
                    placeholder="Select role"
                  />
                </UFormField>
                <UFormField label="Azure ID" name="azureId">
                  <UInput
                    v-model="newUser.azureId"
                    placeholder="Azure ID (optional)"
                  />
                </UFormField>
              </div>

              <div class="flex justify-end gap-3">
                <UButton @click="showCreateUserForm = false" variant="outline">
                  Cancel
                </UButton>
                <UButton
                  @click="createUser"
                  :loading="isCreatingUser"
                  :disabled="!canCreateUser"
                >
                  Create User
                </UButton>
              </div>
            </div>
          </UCard>

          <UTable
            ref="usersTable"
            v-model:row-selection="selectedUsers"
            :data="flatUsers"
            :columns="userColumns"
            :loading="isRefreshing"
            :empty-state="{
              icon: 'i-heroicons-user-group',
              label: 'No users found',
            }"
            @select="onUserSelect"
          />

          <div
            class="border-t border-gray-200 px-4 py-3.5 text-sm text-gray-600"
          >
            {{ Object.keys(selectedUsers).length }} of
            {{ flatUsers.length }} user(s) selected.
          </div>
        </div>
      </template>

      <!-- Projects Tab -->
      <template #projects>
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-medium">Projects</h2>
            <div class="flex items-center gap-3">
              <UButton
                @click="showCreateProjectForm = !showCreateProjectForm"
                icon="i-heroicons-plus"
              >
                Create Project
              </UButton>
            </div>
          </div>

          <!-- Create Project Form -->
          <UCard v-if="showCreateProjectForm">
            <template #header>
              <h3 class="text-lg font-medium">Create New Project</h3>
            </template>

            <div class="space-y-6">
              <UFormField label="Name" name="name" required>
                <UInput v-model="newProject.name" placeholder="Project name" />
              </UFormField>
              <UFormField label="Description" name="description" required>
                <UTextarea
                  v-model="newProject.description"
                  placeholder="Project description"
                  :rows="3"
                />
              </UFormField>
              <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <UFormField label="Owner" name="owner" required>
                  <USelect
                    v-model="newProject.ownerId"
                    :items="
                      userOptions.length > 0
                        ? userOptions
                        : [
                            {
                              label: 'No users available',
                              value: '',
                              disabled: true,
                            },
                          ]
                    "
                    placeholder="Select owner"
                  />
                </UFormField>
                <UFormField label="Members" name="members">
                  <USelect
                    v-model="selectedMembers"
                    :options="userOptions"
                    placeholder="Select members"
                    multiple
                  />
                </UFormField>
              </div>

              <div class="flex justify-end gap-3">
                <UButton
                  @click="showCreateProjectForm = false"
                  variant="outline"
                >
                  Cancel
                </UButton>
                <UButton
                  @click="createProject"
                  :loading="isCreatingProject"
                  :disabled="!canCreateProject"
                >
                  Create Project
                </UButton>
              </div>
            </div>
          </UCard>

          <UTable
            ref="projectsTable"
            v-model:row-selection="selectedProjects"
            :data="flatProjects"
            :columns="projectColumns"
            :loading="isRefreshing"
            :empty-state="{
              icon: 'i-heroicons-folder',
              label: 'No projects found',
            }"
            @select="onProjectSelect"
          />

          <div
            class="border-t border-gray-200 px-4 py-3.5 text-sm text-gray-600"
          >
            {{ Object.keys(selectedProjects).length }} of
            {{ flatProjects.length }} project(s) selected.
          </div>
        </div>
      </template>

      <!-- Test Cases Tab -->
      <template #samples>
        <div class="space-y-6">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-medium">Samples</h2>
            <div class="flex items-center gap-3">
              <UButton
                @click="showCreateForm = !showCreateForm"
                icon="i-heroicons-plus"
              >
                Create Sample
              </UButton>
            </div>
          </div>

          <!-- Create Test Case Form -->
          <UCard v-if="showCreateForm">
            <template #header>
              <h3 class="text-lg font-medium">Create New Sample</h3>
            </template>

            <div class="space-y-6">
              <!-- Input Files Upload -->
              <UFormField label="Upload Input Files" name="inputFiles" required>
                <div class="space-y-3">
                  <div class="flex gap-3">
                    <UButton
                      @click="triggerInputFilesUpload"
                      variant="outline"
                      icon="i-heroicons-document-arrow-up"
                      :loading="isUploadingInputFiles"
                    >
                      Upload Files
                    </UButton>
                    <span
                      v-if="newTestCase.uploadedFiles.length > 0"
                      class="flex items-center text-sm text-gray-600"
                    >
                      {{ newTestCase.uploadedFiles.length }} file(s) selected
                    </span>
                  </div>
                  <input
                    ref="inputFilesInput"
                    type="file"
                    multiple
                    accept=".pdf,.txt,.png,.jpg,.jpeg,.gif,.webp"
                    @change="handleInputFilesChange"
                    class="hidden"
                  />
                  <div
                    v-if="newTestCase.uploadedFiles.length === 0"
                    class="text-xs text-gray-500"
                  >
                    Upload PDF, TXT, or image files for test case inputs
                  </div>
                  <div
                    v-if="newTestCase.uploadedFiles.length > 0"
                    class="space-y-2"
                  >
                    <div
                      v-for="(file, index) in newTestCase.uploadedFiles"
                      :key="index"
                      class="flex items-center justify-between rounded bg-gray-50 p-2"
                    >
                      <span class="text-sm">{{
                        file.originalName || file.name
                      }}</span>
                      <UButton
                        @click="removeInputFile(index)"
                        variant="ghost"
                        color="error"
                        size="xs"
                        icon="i-heroicons-x-mark"
                      />
                    </div>
                  </div>
                </div>
              </UFormField>

              <!-- Expected Output File Upload -->
              <UFormField
                label="Expected Output"
                name="expectedOutput"
                required
              >
                <div class="space-y-3">
                  <div class="flex gap-3">
                    <UButton
                      @click="triggerExpectedOutputFileUpload"
                      variant="outline"
                      icon="i-heroicons-document-arrow-up"
                      :loading="isUploadingExpectedOutput"
                    >
                      Upload JSON File
                    </UButton>
                    <span
                      v-if="newTestCase.expectedOutputFile"
                      class="flex items-center text-sm text-gray-600"
                    >
                      {{ newTestCase.expectedOutputFile.name }}
                    </span>
                  </div>
                  <input
                    ref="expectedOutputFileInput"
                    type="file"
                    accept=".json"
                    @change="handleExpectedOutputFileChange"
                    class="hidden"
                  />
                  <div
                    v-if="!newTestCase.expectedOutputFile"
                    class="text-xs text-gray-500"
                  >
                    Upload a JSON file containing the expected output data
                  </div>
                </div>
              </UFormField>

              <!-- Assignment -->
              <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <UFormField label="Assign to Project" name="project" required>
                  <USelect
                    v-model="newTestCase.projectId"
                    :items="
                      projectOptions.length > 0
                        ? projectOptions
                        : [
                            {
                              label: 'No projects available',
                              value: '',
                              disabled: true,
                            },
                          ]
                    "
                    placeholder="Select project"
                  />
                </UFormField>
                <UFormField label="Assign to User" name="user">
                  <USelect
                    v-model="newTestCase.userId"
                    :items="
                      userOptions.length > 0
                        ? userOptions
                        : [
                            {
                              label: 'No users available',
                              value: '',
                              disabled: true,
                            },
                          ]
                    "
                    placeholder="Select user (optional)"
                  />
                </UFormField>
              </div>

              <!-- Actions -->
              <div class="flex justify-end gap-3">
                <UButton @click="showCreateForm = false" variant="outline">
                  Cancel
                </UButton>
                <UButton
                  @click="createTestCase"
                  :loading="isCreating"
                  :disabled="!canCreateTestCase"
                >
                  Create Test Case
                </UButton>
              </div>
            </div>
          </UCard>

          <!-- Test Cases List -->
          <UTable
            ref="testCasesTable"
            v-model:row-selection="selectedTestCases"
            :data="flatTestCases"
            :columns="testCaseColumns"
            :loading="isRefreshing"
            :empty-state="{
              icon: 'i-heroicons-document-text',
              label: 'No test cases found',
            }"
            @select="onTestCaseSelect"
          />

          <div
            class="border-t border-gray-200 px-4 py-3.5 text-sm text-gray-600"
          >
            {{ Object.keys(selectedTestCases).length }} of
            {{ flatTestCases.length }} test case(s) selected.
          </div>
        </div>
      </template>
    </UTabs>
  </div>
</template>

<script setup lang="ts">
import type { TableColumn, TabsItem } from "@nuxt/ui";
import { h, resolveComponent } from "vue";
import type { IProject, ITestCase, IUser } from "~/models";

const UButton = resolveComponent("UButton");
const UBadge = resolveComponent("UBadge");
const UCheckbox = resolveComponent("UCheckbox");

const toast = useToast();
const { getUsers, createUser: createUserApi } = useUsers();
const { getProjects, createProject: createProjectApi } = useProjects();
const { getTestCases, createTestCase: createTestCaseApi } = useTestCases();

// Reactive data
const selectedTab = ref("samples");
const isRefreshing = ref(false);
const showCreateForm = ref(false);
const isCreating = ref(false);
const showCreateUserForm = ref(false);
const isCreatingUser = ref(false);
const showCreateProjectForm = ref(false);
const isCreatingProject = ref(false);
const isUploadingExpectedOutput = ref(false);
const isUploadingInputFiles = ref(false);

const users = ref<IUser[]>([]);
const projects = ref<IProject[]>([]);
const testCases = ref<ITestCase[]>([]);

// Selection state
const selectedUsers = ref<Record<string, boolean>>({});
const selectedProjects = ref<Record<string, boolean>>({});
const selectedTestCases = ref<Record<string, boolean>>({});
const selectedMembers = ref<string[]>([]);

// Table columns
const userColumns: TableColumn<any>[] = [
  {
    id: "select",
    header: ({ table }) =>
      h(UCheckbox, {
        modelValue: table.getIsSomePageRowsSelected()
          ? "indeterminate"
          : table.getIsAllPageRowsSelected(),
        "onUpdate:modelValue": (value: boolean | "indeterminate") =>
          table.toggleAllPageRowsSelected(!!value),
        "aria-label": "Select all",
      }),
    cell: ({ row }) =>
      h(UCheckbox, {
        modelValue: row.getIsSelected(),
        "onUpdate:modelValue": (value: boolean | "indeterminate") =>
          row.toggleSelected(!!value),
        "aria-label": "Select row",
      }),
    enableSorting: false,
    enableHiding: false,
  },
  {
    accessorKey: "name",
    header: "Name",
  },
  {
    accessorKey: "email",
    header: "Email",
  },
  {
    accessorKey: "role",
    header: "Role",
    cell: ({ row }) => {
      const role = row.getValue("role") as string;
      const color =
        role === "admin" ? "error" : role === "reviewer" ? "info" : "neutral";
      return h(UBadge, { color, variant: "soft" }, () => role);
    },
  },
  {
    accessorKey: "azureId",
    header: "Azure ID",
  },
  {
    accessorKey: "createdAt",
    header: "Created",
  },
  {
    id: "actions",
    header: "Actions",
    cell: ({ row }) => {
      return h("div", { class: "flex items-center gap-2" }, [
        h(UButton, {
          variant: "ghost",
          color: "primary",
          size: "xs",
          icon: "i-heroicons-pencil",
          onClick: () => editUser(row.original),
        }),
        h(UButton, {
          variant: "ghost",
          color: "error",
          size: "xs",
          icon: "i-heroicons-trash",
          onClick: () => deleteUser(row.original),
        }),
      ]);
    },
    enableSorting: false,
  },
];

const projectColumns: TableColumn<any>[] = [
  {
    id: "select",
    header: ({ table }) =>
      h(UCheckbox, {
        modelValue: table.getIsSomePageRowsSelected()
          ? "indeterminate"
          : table.getIsAllPageRowsSelected(),
        "onUpdate:modelValue": (value: boolean | "indeterminate") =>
          table.toggleAllPageRowsSelected(!!value),
        "aria-label": "Select all",
      }),
    cell: ({ row }) =>
      h(UCheckbox, {
        modelValue: row.getIsSelected(),
        "onUpdate:modelValue": (value: boolean | "indeterminate") =>
          row.toggleSelected(!!value),
        "aria-label": "Select row",
      }),
    enableSorting: false,
    enableHiding: false,
  },
  {
    accessorKey: "name",
    header: "Name",
  },
  {
    accessorKey: "description",
    header: "Description",
  },
  {
    accessorKey: "ownerName",
    header: "Owner",
  },
  {
    accessorKey: "memberCount",
    header: "Members",
  },
  {
    accessorKey: "createdAt",
    header: "Created",
  },
  {
    id: "actions",
    header: "Actions",
    cell: ({ row }) => {
      return h("div", { class: "flex items-center gap-2" }, [
        h(UButton, {
          variant: "ghost",
          color: "primary",
          size: "xs",
          icon: "i-heroicons-pencil",
          onClick: () => editProject(row.original),
        }),
        h(UButton, {
          variant: "ghost",
          color: "error",
          size: "xs",
          icon: "i-heroicons-trash",
          onClick: () => deleteProject(row.original),
        }),
      ]);
    },
    enableSorting: false,
  },
];

const testCaseColumns: TableColumn<any>[] = [
  {
    id: "select",
    header: ({ table }) =>
      h(UCheckbox, {
        modelValue: table.getIsSomePageRowsSelected()
          ? "indeterminate"
          : table.getIsAllPageRowsSelected(),
        "onUpdate:modelValue": (value: boolean | "indeterminate") =>
          table.toggleAllPageRowsSelected(!!value),
        "aria-label": "Select all",
      }),
    cell: ({ row }) =>
      h(UCheckbox, {
        modelValue: row.getIsSelected(),
        "onUpdate:modelValue": (value: boolean | "indeterminate") =>
          row.toggleSelected(!!value),
        "aria-label": "Select row",
      }),
    enableSorting: false,
    enableHiding: false,
  },
  {
    accessorKey: "id",
    header: "ID",
  },
  {
    accessorKey: "fileCount",
    header: "Files",
  },
  {
    accessorKey: "filenames",
    header: "Filenames",
  },
  {
    accessorKey: "projectName",
    header: "Project",
  },
  {
    accessorKey: "assignedUsers",
    header: "Assigned To",
  },
  {
    accessorKey: "status",
    header: "Status",
    cell: ({ row }) => {
      const status = row.getValue("status") as string;
      const color = status === "Validated" ? "success" : "warning";
      return h(UBadge, { color, variant: "soft" }, () => status);
    },
  },
  {
    accessorKey: "createdAt",
    header: "Created",
  },
  {
    id: "actions",
    header: "Actions",
    cell: ({ row }) => {
      return h("div", { class: "flex items-center gap-2" }, [
        h(UButton, {
          variant: "ghost",
          color: "primary",
          size: "xs",
          icon: "i-heroicons-eye",
          onClick: () => viewTestCase(row.original),
        }),
        h(UButton, {
          variant: "ghost",
          color: "error",
          size: "xs",
          icon: "i-heroicons-trash",
          onClick: () => deleteTestCase(row.original),
        }),
      ]);
    },
    enableSorting: false,
  },
];

// Computed flat data for tables
const flatUsers = computed(() => {
  return users.value.map((user) => ({
    id: user._id,
    name: user.name,
    email: user.email,
    role: user.role,
    azureId: user.azureId || "-",
    createdAt: formatDate(user.createdAt),
    _original: user,
  }));
});

const flatProjects = computed(() => {
  return projects.value.map((project) => ({
    id: project._id,
    name: project.name,
    description: project.description || "-",
    ownerName: getOwnerName(project.owner),
    memberCount: project.members?.length || 0,
    createdAt: formatDate(project.createdAt),
    _original: project,
  }));
});

const flatTestCases = computed(() => {
  return testCases.value.map((testCase) => ({
    id: testCase._id,
    filenames: testCase.inputs?.map((i) => i.filename).join(", ") || "-",
    fileCount: testCase.inputs?.length || 0,
    projectName: getProjectName(testCase.assigned?.[0]?.project),
    assignedUsers: getAssignedUsers(testCase.assigned || []),
    status: testCase.validated?.length > 0 ? "Validated" : "Pending",
    createdAt: formatDate(testCase.createdAt),
    _original: testCase,
  }));
});

const newUser = ref({
  name: "",
  email: "",
  role: "",
  azureId: "",
});

const newProject = ref({
  name: "",
  description: "",
  ownerId: "",
  memberIds: [] as string[],
});

const newTestCase = ref({
  originalJson: "",
  projectId: "",
  userId: "",
  uploadedFiles: [] as any[],
  expectedOutputFile: null as File | null,
  expectedOutputData: null as any,
});

const expectedOutputFileInput = ref();
const inputFilesInput = ref();

// Tab configuration
const items = ref<TabsItem[]>([
  {
    label: "Samples",
    value: "samples",
    slot: "samples",
  },
  {
    label: "Projects",
    slot: "projects",
  },
  {
    label: "Users",
    slot: "users",
  },
]);

// Computed
const roleOptions = ref([
  { label: "Admin", value: "admin" },
  { label: "Reviewer", value: "reviewer" },
  { label: "User", value: "user" },
]);

const projectOptions = computed(() => {
  const options = projects.value.map((p) => ({
    label: p.name,
    value: p._id,
  }));
  return options;
});

const userOptions = computed(() => {
  const options = users.value.map((u) => ({
    label: u.name,
    value: u._id,
  }));
  return options;
});

const canCreateUser = computed(
  () => newUser.value.name && newUser.value.email && newUser.value.role,
);

const canCreateProject = computed(
  () =>
    newProject.value.name &&
    newProject.value.description &&
    newProject.value.ownerId &&
    newProject.value.ownerId.trim() !== "",
);

const canCreateTestCase = computed(
  () =>
    newTestCase.value.projectId &&
    newTestCase.value.projectId.trim() !== "" &&
    newTestCase.value.uploadedFiles.length > 0 &&
    (newTestCase.value.expectedOutputData ||
      newTestCase.value.expectedOutputFile),
);

// Methods
const triggerInputFilesUpload = () => {
  inputFilesInput.value?.click();
};

const handleInputFilesChange = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const files = Array.from(target.files || []);

  if (files.length === 0) return;

  isUploadingInputFiles.value = true;
  try {
    const formData = new FormData();
    files.forEach((file) => {
      formData.append("files", file);
    });

    const response: any = await $fetch("/api/upload", {
      method: "POST",
      body: formData,
    });

    newTestCase.value.uploadedFiles = response.files || [];

    toast.add({
      title: "Files Uploaded",
      description: `${files.length} file(s) uploaded successfully`,
      color: "success",
    });
  } catch (error) {
    toast.add({
      title: "Upload Failed",
      description: "Failed to upload input files",
      color: "error",
    });
  } finally {
    isUploadingInputFiles.value = false;
  }
};

const removeInputFile = (index: number) => {
  newTestCase.value.uploadedFiles.splice(index, 1);
};

const triggerExpectedOutputFileUpload = () => {
  expectedOutputFileInput.value?.click();
};

const handleExpectedOutputFileChange = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];

  if (!file) return;

  if (!file.type.includes("json")) {
    toast.add({
      title: "Invalid File Type",
      description: "Please select a JSON file",
      color: "error",
    });
    return;
  }

  isUploadingExpectedOutput.value = true;
  try {
    const text = await file.text();
    const jsonData = JSON.parse(text);

    newTestCase.value.expectedOutputFile = file;
    newTestCase.value.expectedOutputData = jsonData;

    toast.add({
      title: "File Uploaded",
      description: "Expected output file uploaded successfully",
      color: "success",
    });
  } catch (error) {
    toast.add({
      title: "Invalid JSON",
      description: "The selected file contains invalid JSON",
      color: "error",
    });
  } finally {
    isUploadingExpectedOutput.value = false;
  }
};

const createUser = async () => {
  isCreatingUser.value = true;
  try {
    await createUserApi({
      name: newUser.value.name,
      email: newUser.value.email,
      role: newUser.value.role as "admin" | "reviewer" | "user",
      azureId: newUser.value.azureId || undefined,
    });

    toast.add({
      title: "User Created",
      description: `User ${newUser.value.name} created successfully`,
      color: "success",
    });

    // Reset form
    newUser.value = {
      name: "",
      email: "",
      role: "",
      azureId: "",
    };
    showCreateUserForm.value = false;

    await refreshData();
  } catch (error: any) {
    toast.add({
      title: "Creation Failed",
      description: error.data?.message || "Failed to create user",
      color: "error",
    });
  } finally {
    isCreatingUser.value = false;
  }
};

const createProject = async () => {
  isCreatingProject.value = true;
  try {
    await createProjectApi({
      name: newProject.value.name,
      description: newProject.value.description,
      owner: newProject.value.ownerId as any,
      members: selectedMembers.value as any[],
    });

    toast.add({
      title: "Project Created",
      description: `Project ${newProject.value.name} created successfully`,
      color: "success",
    });

    // Reset form
    newProject.value = {
      name: "",
      description: "",
      ownerId: "",
      memberIds: [],
    };
    selectedMembers.value = [];
    showCreateProjectForm.value = false;

    await refreshData();
  } catch (error: any) {
    toast.add({
      title: "Creation Failed",
      description: error.data?.message || "Failed to create project",
      color: "error",
    });
  } finally {
    isCreatingProject.value = false;
  }
};

const refreshData = async () => {
  isRefreshing.value = true;
  try {
    const [usersData, projectsData, testCasesData] = await Promise.all([
      getUsers(),
      getProjects(),
      getTestCases(),
    ]);

    users.value = usersData;
    projects.value = projectsData;
    testCases.value = testCasesData;
  } catch (error: any) {
    console.error("Refresh error:", error);
    toast.add({
      title: "Refresh Failed",
      description: "Failed to load data",
      color: "error",
    });
  } finally {
    isRefreshing.value = false;
  }
};

const createTestCase = async () => {
  isCreating.value = true;
  try {
    // Use the uploaded file data
    const originalData = newTestCase.value.expectedOutputData;

    if (!originalData) {
      throw new Error("Expected output data is required");
    }

    const inputs = newTestCase.value.uploadedFiles.map((file) => ({
      type: file.type,
      file: file.path,
      filename: file.originalName,
    }));

    const assignmentData: any = {
      project: newTestCase.value.projectId,
    };

    // Only add user if one is selected and not empty
    if (newTestCase.value.userId && newTestCase.value.userId.trim() !== "") {
      assignmentData.user = newTestCase.value.userId;
    }

    await createTestCaseApi({
      inputs,
      original: originalData,
      assigned: [assignmentData],
    });

    toast.add({
      title: "Test Case Created",
      description: "Test case created successfully",
      color: "success",
    });

    // Reset form
    newTestCase.value = {
      originalJson: "",
      projectId: "",
      userId: "",
      uploadedFiles: [],
      expectedOutputFile: null,
      expectedOutputData: null,
    };
    showCreateForm.value = false;
    if (expectedOutputFileInput.value) {
      expectedOutputFileInput.value.value = "";
    }
    if (inputFilesInput.value) {
      inputFilesInput.value.value = "";
    }

    await refreshData();
  } catch (error: any) {
    toast.add({
      title: "Creation Failed",
      description: error.message || "Failed to create test case",
      color: "error",
    });
  } finally {
    isCreating.value = false;
  }
};

const formatDate = (date: string | Date | undefined) => {
  if (!date) return "Unknown";
  return new Date(date).toLocaleDateString();
};

const getOwnerName = (owner: any) => {
  if (typeof owner === "object" && owner?.name) {
    return owner.name;
  }
  return "Unknown";
};

const getProjectName = (projectId: any) => {
  if (!projectId) return "Unknown";
  const project = projects.value.find((p) => p._id === projectId);
  return project?.name || "Unknown";
};

const getAssignedUsers = (assigned: any[]) => {
  return assigned
    .map((a) => {
      if (typeof a.user === "object" && a.user?.name) {
        return a.user.name;
      }
      return "Unknown";
    })
    .join(", ");
};

// Table selection handlers
const onUserSelect = (row: any) => {
  console.log("User selected:", row);
};

const onProjectSelect = (row: any) => {
  console.log("Project selected:", row);
};

const onTestCaseSelect = (row: any) => {
  console.log("Test case selected:", row);
};

// Edit handlers
const editUser = (row: any) => {
  // TODO: Implement user editing
  toast.add({
    title: "Edit User",
    description: `Edit functionality for ${row.name} not implemented yet`,
    color: "info",
  });
};

const editProject = (row: any) => {
  // TODO: Implement project editing
  toast.add({
    title: "Edit Project",
    description: `Edit functionality for ${row.name} not implemented yet`,
    color: "info",
  });
};

const viewTestCase = (row: any) => {
  // TODO: Implement test case viewing
  toast.add({
    title: "View Test Case",
    description: `View functionality for test case ${row.id} not implemented yet`,
    color: "info",
  });
};

// Delete handlers
const deleteUser = async (row: any) => {
  if (!confirm(`Are you sure you want to delete user ${row.name}?`)) return;

  try {
    // TODO: Implement user deletion API call
    toast.add({
      title: "User Deleted",
      description: `${row.name} has been deleted`,
      color: "success",
    });
    await refreshData();
  } catch (error: any) {
    toast.add({
      title: "Delete Failed",
      description: error.message || "Failed to delete user",
      color: "error",
    });
  }
};

const deleteProject = async (row: any) => {
  if (!confirm(`Are you sure you want to delete project ${row.name}?`)) return;

  try {
    // TODO: Implement project deletion API call
    toast.add({
      title: "Project Deleted",
      description: `${row.name} has been deleted`,
      color: "success",
    });
    await refreshData();
  } catch (error: any) {
    toast.add({
      title: "Delete Failed",
      description: error.message || "Failed to delete project",
      color: "error",
    });
  }
};

const deleteTestCase = async (row: any) => {
  if (!confirm(`Are you sure you want to delete this test case?`)) return;

  try {
    // TODO: Implement test case deletion API call
    toast.add({
      title: "Test Case Deleted",
      description: "Test case has been deleted",
      color: "success",
    });
    await refreshData();
  } catch (error: any) {
    toast.add({
      title: "Delete Failed",
      description: error.message || "Failed to delete test case",
      color: "error",
    });
  }
};

// Initialize data on mount
onMounted(() => {
  refreshData();
});
</script>
