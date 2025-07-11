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
                v-if="Object.keys(selectedUsers).length > 0"
                @click="bulkDeleteUsers"
                color="error"
                variant="outline"
                icon="i-heroicons-trash"
              >
                Delete Selected ({{ Object.keys(selectedUsers).length }})
              </UButton>
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
            <template #header>
              <h3 class="text-lg font-medium">
                {{ editingUserId ? "Edit User" : "Create New User" }}
              </h3>
            </template>

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
                <UButton @click="cancelUserForm" variant="outline">
                  Cancel
                </UButton>
                <UButton
                  @click="createUser"
                  :loading="isCreatingUser"
                  :disabled="!canCreateUser"
                >
                  {{ editingUserId ? "Update User" : "Create User" }}
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
            :get-row-id="(row) => row.id"
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
                v-if="Object.keys(selectedProjects).length > 0"
                @click="bulkDeleteProjects"
                color="error"
                variant="outline"
                icon="i-heroicons-trash"
              >
                Delete Selected ({{ Object.keys(selectedProjects).length }})
              </UButton>
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
              <h3 class="text-lg font-medium">
                {{ editingProjectId ? "Edit Project" : "Create New Project" }}
              </h3>
            </template>

            <div class="space-y-6">
              <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <UFormField label="Name" name="name" required>
                  <UInput
                    v-model="newProject.name"
                    placeholder="Project name"
                  />
                </UFormField>
                <UFormField label="Description" name="description" required>
                  <UTextarea
                    v-model="newProject.description"
                    placeholder="Project description"
                    :rows="3"
                  />
                </UFormField>
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
                    :items="[
                      { label: 'No members', value: null },
                      ...userOptions,
                    ]"
                    placeholder="Select members"
                    multiple
                  />
                </UFormField>
              </div>

              <div class="flex justify-end gap-3">
                <UButton @click="cancelProjectForm" variant="outline">
                  Cancel
                </UButton>
                <UButton
                  @click="createProject"
                  :loading="isCreatingProject"
                  :disabled="!canCreateProject"
                >
                  {{ editingProjectId ? "Update Project" : "Create Project" }}
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
            :get-row-id="(row) => row.id"
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
                v-if="Object.keys(selectedTestCases).length > 0"
                @click="bulkDeleteTestCases"
                color="error"
                variant="outline"
                icon="i-heroicons-trash"
              >
                Delete Selected ({{ Object.keys(selectedTestCases).length }})
              </UButton>
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
              <h3 class="text-lg font-medium">
                {{ editingTestCaseId ? "Edit Sample" : "Create New Sample" }}
              </h3>
            </template>

            <div class="space-y-6">
              <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <!-- Input Files Upload -->
                <UFormField
                  label="Upload Input Files"
                  name="inputFiles"
                  required
                >
                  <div class="space-y-3">
                    <div class="flex gap-3">
                      <UButton
                        @click="triggerInputFilesUpload"
                        variant="outline"
                        icon="i-heroicons-document-arrow-up"
                        :loading="isUploadingInputFiles"
                      >
                        {{
                          editingTestCaseId ? "Replace Files" : "Upload Files"
                        }}
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
                      v-if="
                        newTestCase.uploadedFiles.length === 0 &&
                        !editingTestCaseId
                      "
                      class="text-xs text-gray-500"
                    >
                      Upload PDF, TXT, or image files for test case inputs
                    </div>
                    <div
                      v-if="newTestCase.uploadedFiles.length > 0"
                      class="space-y-2"
                    >
                      <p v-if="editingTestCaseId" class="text-sm text-gray-600">
                        {{ editingTestCaseId ? "Current" : "Selected" }} Files:
                      </p>
                      <div
                        v-for="(file, index) in newTestCase.uploadedFiles"
                        :key="index"
                        class="flex items-center justify-between rounded bg-gray-50 p-2"
                      >
                        <span class="text-sm">{{
                          file.originalName || file.filename || file.name
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
                        {{
                          editingTestCaseId
                            ? "Replace JSON File"
                            : "Upload JSON File"
                        }}
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
                      v-if="
                        !newTestCase.expectedOutputFile && !editingTestCaseId
                      "
                      class="text-xs text-gray-500"
                    >
                      Upload a JSON file containing the expected output data
                    </div>
                  </div>
                </UFormField>

                <UFormField label="Assign to Project" name="project" required>
                  <USelect
                    v-model="newTestCase.projectId"
                    :items="projectOptions"
                    placeholder="Select project"
                  />
                </UFormField>
                <UFormField label="Assign to User" name="user">
                  <USelect
                    v-model="newTestCase.userId"
                    :items="[
                      { label: 'No user assigned', value: null },
                      ...userOptions,
                    ]"
                    placeholder="Select user (optional)"
                  />
                </UFormField>
              </div>

              <!-- Actions -->
              <div class="flex justify-end gap-3">
                <UButton @click="cancelTestCaseForm" variant="outline">
                  Cancel
                </UButton>
                <UButton
                  @click="createTestCase"
                  :loading="isCreating"
                  :disabled="!canCreateTestCase"
                >
                  {{
                    editingTestCaseId ? "Update Test Case" : "Create Test Case"
                  }}
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
            :get-row-id="(row) => row.id"
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
import { h, nextTick, resolveComponent } from "vue";
import type { IProject, ITestCase, IUser } from "~/models";

const UButton = resolveComponent("UButton");
const UBadge = resolveComponent("UBadge");
const UCheckbox = resolveComponent("UCheckbox");

const toast = useToast();
const {
  getUsers,
  createUser: createUserApi,
  updateUser: updateUserApi,
  deleteUser: deleteUserApi,
} = useUsers();
const {
  getProjects,
  createProject: createProjectApi,
  updateProject: updateProjectApi,
  deleteProject: deleteProjectApi,
} = useProjects();
const {
  getTestCases,
  createTestCase: createTestCaseApi,
  updateTestCase: updateTestCaseApi,
  deleteTestCase: deleteTestCaseApi,
} = useTestCases();

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

// Editing state
const editingUserId = ref<string | null>(null);
const editingProjectId = ref<string | null>(null);
const editingTestCaseId = ref<string | null>(null);

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
          icon: "i-heroicons-pencil",
          onClick: () => editTestCase(row.original),
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
  userId: null as string | null,
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
    typeof newProject.value.ownerId === "string" &&
    newProject.value.ownerId.trim() !== "",
);

const canCreateTestCase = computed(
  () =>
    newTestCase.value.projectId &&
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
  const isEditing = !!editingUserId.value;

  try {
    if (isEditing) {
      await updateUserApi(editingUserId.value!, {
        name: newUser.value.name,
        email: newUser.value.email,
        role: newUser.value.role as "admin" | "reviewer" | "user",
        azureId: newUser.value.azureId, // Allow empty string to clear Azure ID
      });
      toast.add({
        title: "User Updated",
        description: `User ${newUser.value.name} updated successfully`,
        color: "success",
      });
    } else {
      await createUserApi({
        name: newUser.value.name,
        email: newUser.value.email,
        role: newUser.value.role as "admin" | "reviewer" | "user",
        azureId: newUser.value.azureId, // Allow empty string
      });

      toast.add({
        title: "User Created",
        description: `User ${newUser.value.name} created successfully`,
        color: "success",
      });
    }

    cancelUserForm();
    await refreshData();
  } catch (error: any) {
    toast.add({
      title: isEditing ? "Update Failed" : "Creation Failed",
      description:
        error.data?.message ||
        `Failed to ${isEditing ? "update" : "create"} user`,
      color: "error",
    });
  } finally {
    isCreatingUser.value = false;
  }
};

const createProject = async () => {
  isCreatingProject.value = true;
  const isEditing = !!editingProjectId.value;

  try {
    // Filter out null values from selectedMembers
    const validMembers = selectedMembers.value.filter(
      (memberId) => memberId !== null && memberId !== "",
    );

    if (isEditing) {
      await updateProjectApi(editingProjectId.value!, {
        name: newProject.value.name,
        description: newProject.value.description,
        owner: newProject.value.ownerId as any,
        members: validMembers as any[],
      });
      toast.add({
        title: "Project Updated",
        description: `Project ${newProject.value.name} updated successfully`,
        color: "success",
      });
    } else {
      await createProjectApi({
        name: newProject.value.name,
        description: newProject.value.description,
        owner: newProject.value.ownerId as any,
        members: validMembers as any[],
      });

      toast.add({
        title: "Project Created",
        description: `Project ${newProject.value.name} created successfully`,
        color: "success",
      });
    }

    cancelProjectForm();
    await refreshData();
  } catch (error: any) {
    toast.add({
      title: isEditing ? "Update Failed" : "Creation Failed",
      description:
        error.data?.message ||
        `Failed to ${isEditing ? "update" : "create"} project`,
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
  const isEditing = !!editingTestCaseId.value;

  try {
    // Use the uploaded file data
    const originalData = newTestCase.value.expectedOutputData;

    if (!originalData) {
      throw new Error("Expected output data is required");
    }

    const inputs = newTestCase.value.uploadedFiles.map((file) => ({
      type: file.type,
      file: file.path || file.file,
      filename: file.originalName || file.filename,
    }));

    const assignmentData: any = {
      project: newTestCase.value.projectId,
    };

    // Only add user if one is selected and not empty/null
    if (
      newTestCase.value.userId &&
      newTestCase.value.userId !== null &&
      typeof newTestCase.value.userId === "string" &&
      newTestCase.value.userId.trim() !== ""
    ) {
      assignmentData.user = newTestCase.value.userId;
    }

    if (isEditing) {
      const result = await updateTestCaseApi(editingTestCaseId.value!, {
        inputs,
        original: originalData,
        assigned: [assignmentData],
      });
      toast.add({
        title: "Test Case Updated",
        description: "Test case updated successfully",
        color: "success",
      });
    } else {
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
    }

    cancelTestCaseForm();
    await refreshData();
  } catch (error: any) {
    toast.add({
      title: isEditing ? "Update Failed" : "Creation Failed",
      description:
        error.message ||
        `Failed to ${isEditing ? "update" : "create"} test case`,
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

const getProjectName = (projectData: any) => {
  if (!projectData) return "Unknown";

  // If it's already a populated object with name, use that
  if (typeof projectData === "object" && projectData.name) {
    return projectData.name;
  }

  // Otherwise, treat it as an ID and look it up
  const project = projects.value.find((p) => p._id === projectData);
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

// Edit handlers
const editUser = (row: any) => {
  // Populate the form with existing user data
  newUser.value = {
    name: row._original.name,
    email: row._original.email,
    role: row._original.role,
    azureId: row._original.azureId || "",
  };
  editingUserId.value = row._original._id;
  showCreateUserForm.value = true;
  toast.add({
    title: "Edit Mode",
    description: `Editing user ${row.name}. Form populated with current data.`,
    color: "info",
  });
};

const editProject = (row: any) => {
  // Populate the form with existing project data
  const original = row._original;
  const ownerId = original.owner?._id || original.owner || "";
  const memberIds = original.members?.map((m: any) => m._id || m) || [];

  newProject.value = {
    name: original.name,
    description: original.description,
    ownerId: ownerId,
    memberIds: memberIds,
  };
  selectedMembers.value = memberIds;
  editingProjectId.value = original._id;
  showCreateProjectForm.value = true;
  toast.add({
    title: "Edit Mode",
    description: `Editing project ${row.name}. Form populated with current data.`,
    color: "info",
  });
};

const editTestCase = (row: any) => {
  // Populate the form with existing test case data
  const original = row._original;
  const userId =
    original.assigned?.[0]?.user?._id || original.assigned?.[0]?.user || null;

  // Handle project ID - it might be populated (object) or just the ID (string)
  const projectId =
    original.assigned?.[0]?.project?._id ||
    original.assigned?.[0]?.project ||
    "";

  newTestCase.value = {
    originalJson: JSON.stringify(original.original, null, 2),
    projectId: projectId,
    userId: userId,
    uploadedFiles: original.inputs || [],
    expectedOutputFile: null,
    expectedOutputData: original.original,
  };
  editingTestCaseId.value = original._id;
  showCreateForm.value = true;

  // Reset file inputs to avoid potential null references
  nextTick(() => {
    if (expectedOutputFileInput.value) {
      expectedOutputFileInput.value.value = "";
    }
    if (inputFilesInput.value) {
      inputFilesInput.value.value = "";
    }
  });

  toast.add({
    title: "Edit Mode",
    description: `Editing test case ${row.id}. Form populated with current data.`,
    color: "info",
  });
};

// Delete handlers
const deleteUser = async (row: any) => {
  if (!confirm(`Are you sure you want to delete user ${row.name}?`)) return;

  try {
    await deleteUserApi(row._original._id);
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
    await deleteProjectApi(row._original._id);
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
    await deleteTestCaseApi(row._original._id);
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

// Bulk delete handlers
const bulkDeleteUsers = async () => {
  const selectedUserIds = Object.keys(selectedUsers.value).filter(
    (id) => selectedUsers.value[id],
  );

  if (selectedUserIds.length === 0) return;

  const userNames = selectedUserIds
    .map((id) => {
      const user = users.value.find((u) => u._id === id);
      return user?.name || "Unknown";
    })
    .join(", ");

  if (
    !confirm(
      `Are you sure you want to delete ${selectedUserIds.length} user(s): ${userNames}?`,
    )
  )
    return;

  try {
    await Promise.all(selectedUserIds.map((id) => deleteUserApi(id)));

    toast.add({
      title: "Users Deleted",
      description: `${selectedUserIds.length} user(s) have been deleted`,
      color: "success",
    });

    selectedUsers.value = {};
    await refreshData();
  } catch (error: any) {
    console.error("Bulk delete users error:", error);
    toast.add({
      title: "Bulk Delete Failed",
      description: error.message || "Failed to delete users",
      color: "error",
    });
  }
};

const bulkDeleteProjects = async () => {
  const selectedProjectIds = Object.keys(selectedProjects.value).filter(
    (id) => selectedProjects.value[id],
  );

  if (selectedProjectIds.length === 0) return;

  const projectNames = selectedProjectIds
    .map((id) => {
      const project = projects.value.find((p) => p._id === id);
      return project?.name || "Unknown";
    })
    .join(", ");

  if (
    !confirm(
      `Are you sure you want to delete ${selectedProjectIds.length} project(s): ${projectNames}?`,
    )
  )
    return;

  try {
    await Promise.all(selectedProjectIds.map((id) => deleteProjectApi(id)));

    toast.add({
      title: "Projects Deleted",
      description: `${selectedProjectIds.length} project(s) have been deleted`,
      color: "success",
    });

    selectedProjects.value = {};
    await refreshData();
  } catch (error: any) {
    toast.add({
      title: "Bulk Delete Failed",
      description: error.message || "Failed to delete projects",
      color: "error",
    });
  }
};

const bulkDeleteTestCases = async () => {
  const selectedTestCaseIds = Object.keys(selectedTestCases.value).filter(
    (id) => selectedTestCases.value[id],
  );

  if (selectedTestCaseIds.length === 0) return;

  if (
    !confirm(
      `Are you sure you want to delete ${selectedTestCaseIds.length} test case(s)?`,
    )
  )
    return;

  try {
    await Promise.all(selectedTestCaseIds.map((id) => deleteTestCaseApi(id)));

    toast.add({
      title: "Test Cases Deleted",
      description: `${selectedTestCaseIds.length} test case(s) have been deleted`,
      color: "success",
    });

    selectedTestCases.value = {};
    await refreshData();
  } catch (error: any) {
    console.error("Bulk delete test cases error:", error);
    toast.add({
      title: "Bulk Delete Failed",
      description: error.message || "Failed to delete test cases",
      color: "error",
    });
  }
};

// Form cancel handlers
const cancelUserForm = () => {
  showCreateUserForm.value = false;
  editingUserId.value = null;
  newUser.value = {
    name: "",
    email: "",
    role: "",
    azureId: "",
  };
};

const cancelProjectForm = () => {
  showCreateProjectForm.value = false;
  editingProjectId.value = null;
  newProject.value = {
    name: "",
    description: "",
    ownerId: "",
    memberIds: [],
  };
  selectedMembers.value = [];
};

const cancelTestCaseForm = () => {
  showCreateForm.value = false;
  editingTestCaseId.value = null;
  newTestCase.value = {
    originalJson: "",
    projectId: "",
    userId: null,
    uploadedFiles: [],
    expectedOutputFile: null,
    expectedOutputData: null,
  };

  // Reset file inputs safely
  nextTick(() => {
    if (expectedOutputFileInput.value) {
      expectedOutputFileInput.value.value = "";
    }
    if (inputFilesInput.value) {
      inputFilesInput.value.value = "";
    }
  });
};

// Initialize data on mount
onMounted(() => {
  refreshData();
});
</script>
